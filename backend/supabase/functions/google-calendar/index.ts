import { calendarEvent, digest, type ScheduleRow } from "./events.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
const env = (key: string) => {
  const value = Deno.env.get(key);
  if (!value) throw new Error("configuration_missing");
  return value;
};
const fetchWithTimeout = (url: string, init: RequestInit = {}) =>
  fetch(url, { ...init, signal: AbortSignal.timeout(10000) });
async function db(path: string, method = "GET", body?: unknown) {
  const response = await fetchWithTimeout(
    `${env("SUPABASE_URL")}/rest/v1/${path}`,
    {
      method,
      headers: {
        apikey: env("SUPABASE_SERVICE_ROLE_KEY"),
        Authorization: `Bearer ${env("SUPABASE_SERVICE_ROLE_KEY")}`,
        "Content-Type": "application/json",
        Prefer: "return=representation,resolution=merge-duplicates",
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    },
  );
  if (!response.ok) throw new Error("storage_failed");
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}
async function key() {
  const bytes = Uint8Array.from(
    atob(env("GOOGLE_CALENDAR_TOKEN_KEY")),
    (c) => c.charCodeAt(0),
  );
  if (bytes.length !== 32) throw new Error("configuration_missing");
  return crypto.subtle.importKey("raw", bytes, "AES-GCM", false, [
    "encrypt",
    "decrypt",
  ]);
}
async function seal(token: string, userId: string) {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv, additionalData: new TextEncoder().encode(userId) },
    await key(),
    new TextEncoder().encode(token),
  );
  return btoa(String.fromCharCode(...iv, ...new Uint8Array(encrypted)));
}
async function unseal(value: string, userId: string) {
  const bytes = Uint8Array.from(atob(value), (c) => c.charCodeAt(0));
  const decrypted = await crypto.subtle.decrypt(
    {
      name: "AES-GCM",
      iv: bytes.slice(0, 12),
      additionalData: new TextEncoder().encode(userId),
    },
    await key(),
    bytes.slice(12),
  );
  return new TextDecoder().decode(decrypted);
}
async function exchange(params: Record<string, string>) {
  const response = await fetchWithTimeout(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        ...params,
        client_id: env("GOOGLE_CALENDAR_CLIENT_ID"),
        client_secret: env("GOOGLE_CALENDAR_CLIENT_SECRET"),
      }),
    },
  );
  const result = await response.json();
  if (!response.ok) {
    throw new Error(
      result.error === "invalid_grant" ? "reconnect_required" : "google_failed",
    );
  }
  return result;
}
async function google(
  token: string,
  path: string,
  method = "GET",
  body?: unknown,
) {
  return fetchWithTimeout(`https://www.googleapis.com/calendar/v3/${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}
const redirectUri = () => `${env("SUPABASE_URL")}/functions/v1/google-calendar`;
const connectionPath = (user: string) =>
  `google_calendar_connections?user_id=eq.${user}`;

async function callback(url: URL) {
  const state = url.searchParams.get("state") ?? "";
  if (!/^[a-f0-9]{64}$/.test(state)) {
    return json({ error: "invalid_state" }, 400);
  }
  // DELETE ... RETURNING consumes the random, expiring state exactly once.
  const states = await db(
    `google_calendar_oauth_states?state=eq.${state}&expires_at=gt.${
      encodeURIComponent(new Date().toISOString())
    }`,
    "DELETE",
  );
  if (!states?.length) return json({ error: "expired_state" }, 400);
  const user = states[0].user_id;
  if (url.searchParams.has("error")) return callbackPage(false);
  const code = url.searchParams.get("code");
  if (!code) return callbackPage(false);
  const tokens = await exchange({
    code,
    grant_type: "authorization_code",
    redirect_uri: redirectUri(),
  });
  if (!tokens.refresh_token) throw new Error("reconnect_required");
  const response = await google(tokens.access_token, "calendars/primary");
  if (!response.ok) throw new Error("permission_required");
  const calendar = await response.json();
  const worker = crypto.randomUUID();
  let old = (await db(connectionPath(user)))[0];
  if (
    old &&
    !(await db("rpc/claim_google_calendar_sync", "POST", {
      owner: user,
      worker,
    }))
  ) throw new Error("sync_busy");
  const leasePath = `${connectionPath(user)}&lease_id=eq.${worker}`;
  try {
    if (old) old = (await db(leasePath))[0];
    const sameCalendar = old?.calendar_id === calendar.id;
    const data = {
      user_id: user,
      refresh_token_encrypted: await seal(tokens.refresh_token, user),
      calendar_id: calendar.id,
      time_zone: calendar.timeZone,
      generation: sameCalendar ? old.generation : crypto.randomUUID(),
      events: sameCalendar ? old.events : {},
      updated_at: new Date().toISOString(),
    };
    if (old) await db(leasePath, "PATCH", data);
    else await db("google_calendar_connections", "POST", data);
  } finally {
    if (old) {
      await db(leasePath, "PATCH", { lease_until: null, lease_id: null });
    }
  }
  return callbackPage(true);
}
function callbackPage(_success: boolean) {
  // The app reads connection status when it resumes. No credentials travel
  // through this URL. Set a fixed HTTPS return URL for Flutter web builds.
  return new Response(null, {
    status: 303,
    headers: {
      Location: Deno.env.get("GOOGLE_CALENDAR_RETURN_URL") ??
        "helpout://calendar-callback",
      "Cache-Control": "no-store",
    },
  });
}

type EventMap = Record<string, { id: string; fingerprint: string }>;
async function sync(user: string) {
  const existing = (await db(connectionPath(user)))[0];
  if (!existing?.refresh_token_encrypted) return { connected: false };
  const worker = crypto.randomUUID();
  if (
    !(await db("rpc/claim_google_calendar_sync", "POST", {
      owner: user,
      worker,
    }))
  ) throw new Error("sync_busy");
  const leasePath = `${connectionPath(user)}&lease_id=eq.${worker}`;
  try {
    // Re-read after obtaining the lease, so another device's completed map wins.
    const connection = (await db(leasePath))[0];
    const tokens = await exchange({
      grant_type: "refresh_token",
      refresh_token: await unseal(connection.refresh_token_encrypted, user),
    });
    const calendar = encodeURIComponent(connection.calendar_id);
    const zoneResponse = await google(
      tokens.access_token,
      `calendars/${calendar}`,
    );
    if (!zoneResponse.ok) throw new Error("permission_required");
    const timeZone = (await zoneResponse.json()).timeZone;
    const rows: ScheduleRow[] = await db(
      `schedule_entries?user_id=eq.${user}&order=id`,
    );
    const events: EventMap = connection.events;
    const wanted = new Set<string>();
    const deadline = Date.now() + 45000;
    const persist = () =>
      db(leasePath, "PATCH", {
        events,
        time_zone: timeZone,
        updated_at: new Date().toISOString(),
      });
    for (const row of rows) {
      if (Date.now() > deadline) throw new Error("retry_required");
      const event = calendarEvent(row, timeZone);
      if (!event) continue;
      wanted.add(row.id);
      const fingerprint = await digest(JSON.stringify(event));
      const previous = events[row.id];
      if (previous?.fingerprint === fingerprint) continue;
      // Persist the id before calling Google: a lost response can be safely
      // retried without inserting a duplicate event.
      if (!previous) {
        events[row.id] = {
          id: await digest(`${user}:${connection.generation}:${row.id}`),
          fingerprint: "",
        };
        await persist();
      }
      const id = events[row.id].id;
      let response = await google(
        tokens.access_token,
        `calendars/${calendar}/events/${id}`,
        "PATCH",
        event,
      );
      if (response.status === 404) {
        response = await google(
          tokens.access_token,
          `calendars/${calendar}/events`,
          "POST",
          { ...event, id },
        );
        if (response.status === 409) {
          response = await google(
            tokens.access_token,
            `calendars/${calendar}/events/${id}`,
            "PATCH",
            event,
          );
        }
      }
      if (response.status === 410) {
        // Google retains tombstones for deleted ids. Reusing a Timing id must
        // create a fresh event id, persisted before insertion for safe retries.
        const replacement = await digest(
          `${user}:${connection.generation}:${row.id}:${crypto.randomUUID()}`,
        );
        events[row.id] = { id: replacement, fingerprint: "" };
        await persist();
        response = await google(
          tokens.access_token,
          `calendars/${calendar}/events`,
          "POST",
          { ...event, id: replacement },
        );
      }
      if (!response.ok) {
        throw new Error(
          response.status === 401 || response.status === 403
            ? "permission_required"
            : "google_failed",
        );
      }
      events[row.id].fingerprint = fingerprint;
      await persist();
    }
    for (const [entry, value] of Object.entries(events)) {
      if (wanted.has(entry)) continue;
      if (Date.now() > deadline) throw new Error("retry_required");
      const response = await google(
        tokens.access_token,
        `calendars/${calendar}/events/${value.id}`,
        "DELETE",
      );
      if (!response.ok && response.status !== 404 && response.status !== 410) {
        throw new Error("google_failed");
      }
      delete events[entry];
      await persist();
    }
    return { connected: true, timeZone };
  } finally {
    await db(leasePath, "PATCH", { lease_until: null, lease_id: null });
  }
}

export async function handleRequest(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }
  try {
    const url = new URL(request.url);
    if (request.method === "GET") return await callback(url);
    if (request.method !== "POST") {
      return json({ error: "method_not_allowed" }, 405);
    }
    const authorization = request.headers.get("Authorization") ?? "";
    const auth = await fetchWithTimeout(`${env("SUPABASE_URL")}/auth/v1/user`, {
      headers: {
        Authorization: authorization,
        apikey: env("SUPABASE_ANON_KEY"),
      },
    });
    if (!auth.ok) return json({ error: "unauthorized" }, 401);
    const user = (await auth.json()).id;
    const { action } = await request.json();
    if (action === "connect") {
      // Check required secrets before opening the browser.
      await key();
      env("GOOGLE_CALENDAR_CLIENT_SECRET");
      const state = await digest(crypto.randomUUID() + crypto.randomUUID());
      await db(`google_calendar_oauth_states?user_id=eq.${user}`, "DELETE");
      await db("google_calendar_oauth_states", "POST", {
        user_id: user,
        state,
      });
      const oauth = new URL("https://accounts.google.com/o/oauth2/v2/auth");
      oauth.search = new URLSearchParams({
        client_id: env("GOOGLE_CALENDAR_CLIENT_ID"),
        redirect_uri: redirectUri(),
        response_type: "code",
        access_type: "offline",
        prompt: "consent",
        state,
        scope:
          "https://www.googleapis.com/auth/calendar.events.owned https://www.googleapis.com/auth/calendar.calendars.readonly",
      }).toString();
      return json({ url: oauth.toString() });
    }
    if (action === "status") {
      const connection = (await db(connectionPath(user)))[0];
      return json({
        connected: !!connection?.refresh_token_encrypted,
        timeZone: connection?.time_zone,
      });
    }
    if (action === "disconnect") {
      const connection = (await db(connectionPath(user)))[0];
      const worker = crypto.randomUUID();
      if (
        connection &&
        !(await db("rpc/claim_google_calendar_sync", "POST", {
          owner: user,
          worker,
        }))
      ) throw new Error("sync_busy");
      const leasePath = `${connectionPath(user)}&lease_id=eq.${worker}`;
      try {
        await db(`google_calendar_oauth_states?user_id=eq.${user}`, "DELETE");
        // Keep event ids for duplicate-free reconnection, remove credentials.
        if (connection) {
          await db(leasePath, "PATCH", { refresh_token_encrypted: "" });
        }
      } finally {
        if (connection) {
          await db(leasePath, "PATCH", { lease_until: null, lease_id: null });
        }
      }
      return json({ connected: false });
    }
    if (action === "sync") return json(await sync(user));
    return json({ error: "invalid_action" }, 400);
  } catch (error) {
    const allowed = [
      "configuration_missing",
      "reconnect_required",
      "permission_required",
      "sync_busy",
      "retry_required",
      "google_failed",
      "storage_failed",
    ];
    const code = error instanceof Error && allowed.includes(error.message)
      ? error.message
      : "calendar_failed";
    // Never return/log OAuth tokens, authorization codes, or raw upstream errors.
    return json({ error: code }, 503);
  }
}

if (import.meta.main) Deno.serve(handleRequest);

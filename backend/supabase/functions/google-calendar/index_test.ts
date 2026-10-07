import { handleRequest } from "./index.ts";
const assert = (condition: unknown) => {
  if (!condition) throw new Error("Assertion failed");
};
const json = (value: unknown, status = 200) =>
  new Response(JSON.stringify(value), {
    status,
    headers: { "Content-Type": "application/json" },
  });
const post = (action: string) =>
  new Request("https://project.supabase.co/functions/v1/google-calendar", {
    method: "POST",
    headers: {
      Authorization: "Bearer user-jwt",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ action }),
  });
for (
  const [key, value] of Object.entries({
    SUPABASE_URL: "https://project.supabase.co",
    SUPABASE_SERVICE_ROLE_KEY: "test-service",
    SUPABASE_ANON_KEY: "test-anon",
    GOOGLE_CALENDAR_CLIENT_ID: "test-client",
    GOOGLE_CALENDAR_CLIENT_SECRET: "test-secret",
    GOOGLE_CALENDAR_TOKEN_KEY: btoa("0".repeat(32)),
  })
) Deno.env.set(key, value);

Deno.test("unauthenticated calls cannot read credentials or sync", async () => {
  const original = globalThis.fetch;
  const paths: string[] = [];
  globalThis.fetch = (input) => {
    paths.push(String(input));
    return Promise.resolve(json({}, 401));
  };
  try {
    const response = await handleRequest(post("sync"));
    assert(response.status === 401);
    assert(paths.length === 1 && paths[0].endsWith("/auth/v1/user"));
  } finally {
    globalThis.fetch = original;
  }
});
Deno.test("consumed or expired callback state never exchanges Google tokens", async () => {
  const original = globalThis.fetch;
  const paths: string[] = [];
  globalThis.fetch = (input) => {
    paths.push(String(input));
    return Promise.resolve(json([]));
  };
  try {
    const response = await handleRequest(
      new Request(
        `https://project.supabase.co/functions/v1/google-calendar?state=${
          "a".repeat(64)
        }&code=secret-code`,
      ),
    );
    assert(response.status === 400);
    assert(
      paths.length === 1 && paths[0].includes("google_calendar_oauth_states"),
    );
    assert(!(await response.text()).includes("secret-code"));
  } finally {
    globalThis.fetch = original;
  }
});
Deno.test("disconnect removes credential while retaining mapped events and releasing lease", async () => {
  const original = globalThis.fetch;
  const writes: Record<string, unknown>[] = [];
  globalThis.fetch = (input, init) => {
    const path = String(input);
    if (path.endsWith("/auth/v1/user")) {
      return Promise.resolve(json({ id: "user-1" }));
    }
    if (path.includes("rpc/claim_google_calendar_sync")) {
      return Promise.resolve(json(true));
    }
    if (init?.method === "PATCH") {
      writes.push(JSON.parse(init.body as string));
      return Promise.resolve(json([]));
    }
    return Promise.resolve(
      json([{
        refresh_token_encrypted: "ciphertext",
        events: { entry: { id: "event" } },
      }]),
    );
  };
  try {
    const response = await handleRequest(post("disconnect"));
    assert(response.ok);
    assert(
      writes[0].refresh_token_encrypted === "" && !("events" in writes[0]),
    );
    assert(writes[1].lease_id === null);
  } finally {
    globalThis.fetch = original;
  }
});
Deno.test("disconnected accounts do not invoke Google even if old event map exists", async () => {
  const original = globalThis.fetch;
  const paths: string[] = [];
  globalThis.fetch = (input) => {
    const path = String(input);
    paths.push(path);
    return Promise.resolve(
      json(
        path.endsWith("/auth/v1/user") ? { id: "user-1" } : [{
          refresh_token_encrypted: "",
          events: { entry: { id: "event" } },
        }],
      ),
    );
  };
  try {
    const response = await handleRequest(post("sync"));
    assert((await response.json()).connected === false);
    assert(
      paths.every((path) => path.startsWith("https://project.supabase.co/")),
    );
  } finally {
    globalThis.fetch = original;
  }
});

Deno.test("lost insert response retries without duplicates; edits and deletes reconcile", async () => {
  const user = "user-1";
  const iv = new Uint8Array(12);
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode("0".repeat(32)),
    "AES-GCM",
    false,
    ["encrypt"],
  );
  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv, additionalData: new TextEncoder().encode(user) },
    key,
    new TextEncoder().encode("google-refresh-secret"),
  );
  const connection = {
    user_id: user,
    refresh_token_encrypted: btoa(
      String.fromCharCode(...iv, ...new Uint8Array(encrypted)),
    ),
    calendar_id: "primary",
    generation: "generation",
    events: {} as Record<string, unknown>,
    lease_id: null as string | null,
  };
  let rows = [{
    id: "entry-1",
    title: "Study",
    weekday: 1,
    start_minutes: 540,
    end_minutes: 600,
    active_from: "2026-10-06",
    active_until: null,
  }];
  const events = new Map<string, Record<string, unknown>>();
  let lostResponse = true;
  let inserts = 0;
  let patches = 0;
  const original = globalThis.fetch;
  globalThis.fetch = async (input, init) => {
    const url = String(input);
    const body = init?.body
      ? JSON.parse(String(init.body).startsWith("{") ? String(init.body) : "{}")
      : {};
    if (url.endsWith("/auth/v1/user")) return json({ id: user });
    if (url.includes("/rest/v1/rpc/")) {
      connection.lease_id = body.worker;
      return json(true);
    }
    if (url.includes("/rest/v1/schedule_entries")) return json(rows);
    if (url.includes("/rest/v1/google_calendar_connections")) {
      if (init?.method === "PATCH") Object.assign(connection, body);
      return json([connection]);
    }
    if (url === "https://oauth2.googleapis.com/token") {
      return json({ access_token: "google-access-secret" });
    }
    if (url.endsWith("/calendars/primary")) {
      return json({ timeZone: "America/Fortaleza" });
    }
    if (url.endsWith("/events") && init?.method === "POST") {
      inserts++;
      events.set(body.id, body);
      if (lostResponse) {
        lostResponse = false;
        throw new Error("response lost");
      }
      return json(body);
    }
    const id = url.split("/").at(-1)!;
    if (init?.method === "PATCH") {
      if (!events.has(id)) return json({}, 404);
      patches++;
      events.set(id, body);
      return json(body);
    }
    if (init?.method === "DELETE") {
      events.delete(id);
      return new Response(null, { status: 204 });
    }
    throw new Error("Unexpected request");
  };
  try {
    let response = await handleRequest(post("sync"));
    assert(response.status === 503);
    assert(!(await response.text()).includes("google-refresh-secret"));
    assert(connection.lease_id === null);
    assert((await handleRequest(post("sync"))).ok);
    assert(inserts === 1 && events.size === 1);
    const before = patches;
    assert((await handleRequest(post("sync"))).ok);
    assert(patches === before);
    rows[0].title = "Updated study";
    assert((await handleRequest(post("sync"))).ok);
    assert(Array.from(events.values())[0].summary === "Updated study");
    rows = [];
    assert((await handleRequest(post("sync"))).ok);
    assert(events.size === 0 && Object.keys(connection.events).length === 0);
  } finally {
    globalThis.fetch = original;
  }
});

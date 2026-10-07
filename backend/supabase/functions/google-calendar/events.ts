export interface ScheduleRow {
  id: string;
  title: string;
  weekday: number;
  start_minutes: number | null;
  end_minutes: number | null;
  active_from: string;
  active_until: string | null;
}
const dayMs = 86400000;
const date = (value: Date) => value.toISOString().slice(0, 10);
const at = (day: Date, minutes: number) =>
  new Date(day.getTime() + minutes * 60000).toISOString().slice(0, 19);

// Dates are calculated in UTC solely as calendar arithmetic. Wall-clock times
// are interpreted by Google in the named zone, preserving DST transitions.
export function calendarEvent(row: ScheduleRow, timeZone: string) {
  const start = new Date(`${row.active_from}T00:00:00Z`);
  const weekday = start.getUTCDay() || 7;
  start.setUTCDate(start.getUTCDate() + (row.weekday - weekday + 7) % 7);
  const until = row.active_until
    ? new Date(`${row.active_until}T00:00:00Z`)
    : null;
  if (until && start > until) return null;
  const count = until
    ? Math.floor((until.getTime() - start.getTime()) / (7 * dayMs)) + 1
    : null;
  const recurrence = [
    `RRULE:FREQ=WEEKLY;BYDAY=${
      ["MO", "TU", "WE", "TH", "FR", "SA", "SU"][row.weekday - 1]
    }${count ? `;COUNT=${count}` : ""}`,
  ];
  const timing = row.start_minutes == null
    ? {
      start: { date: date(start) },
      end: { date: date(new Date(start.getTime() + dayMs)) },
    }
    : {
      start: { dateTime: at(start, row.start_minutes), timeZone },
      end: {
        dateTime: at(start, row.end_minutes ?? row.start_minutes + 60),
        timeZone,
      },
    };
  return {
    summary: row.title,
    description: "Timing",
    ...timing,
    recurrence,
    extendedProperties: { private: { timingEntryId: row.id } },
  };
}
export async function digest(value: string): Promise<string> {
  const hash = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return Array.from(
    new Uint8Array(hash),
    (b) => b.toString(16).padStart(2, "0"),
  ).join("");
}

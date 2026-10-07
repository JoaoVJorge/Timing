import { calendarEvent, type ScheduleRow } from "./events.ts";
function equal(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
const row: ScheduleRow = {
  id: "1",
  title: "Estudar",
  weekday: 1,
  start_minutes: 540,
  end_minutes: 600,
  active_from: "2026-10-06",
  active_until: "2026-10-26",
};
Deno.test("first matching weekday and inclusive final occurrence", () => {
  const event = calendarEvent(row, "America/Fortaleza")!;
  equal(event.start, {
    dateTime: "2026-10-12T09:00:00",
    timeZone: "America/Fortaleza",
  });
  equal(event.recurrence, ["RRULE:FREQ=WEEKLY;BYDAY=MO;COUNT=3"]);
});
Deno.test("period with no matching weekday creates no event", () => {
  equal(calendarEvent({ ...row, active_until: "2026-10-10" }, "UTC"), null);
});
Deno.test("unbounded all-day series uses exclusive next day end", () => {
  const event = calendarEvent({
    ...row,
    weekday: 7,
    start_minutes: null,
    end_minutes: null,
    active_until: null,
  }, "UTC")!;
  equal(event.start, { date: "2026-10-11" });
  equal(event.end, { date: "2026-10-12" });
  equal(event.recurrence, ["RRULE:FREQ=WEEKLY;BYDAY=SU"]);
});
Deno.test("missing end defaults to one hour and rolls over midnight", () => {
  const event = calendarEvent({
    ...row,
    start_minutes: 1410,
    end_minutes: null,
  }, "America/New_York")!;
  equal(event.end, {
    dateTime: "2026-10-13T00:30:00",
    timeZone: "America/New_York",
  });
});
Deno.test("recurrence across DST preserves wall-clock time in an IANA zone", () => {
  const event = calendarEvent(
    { ...row, active_until: "2026-11-09" },
    "America/New_York",
  )!;
  equal(event.start, {
    dateTime: "2026-10-12T09:00:00",
    timeZone: "America/New_York",
  });
  equal(event.recurrence, ["RRULE:FREQ=WEEKLY;BYDAY=MO;COUNT=5"]);
});

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/update_schedule_entry_use_case.dart";

class _FakeScheduleRepository implements ScheduleRepository {
  _FakeScheduleRepository(this._entries);

  List<ScheduleEntryEntity> _entries;
  List<ScheduleEntryEntity>? savedEntries;

  @override
  Future<Either<AppError, List<ScheduleEntryEntity>>> getEntries() async =>
      Right(_entries);

  @override
  Future<Either<AppError, void>> saveEntries(
    List<ScheduleEntryEntity> entries,
  ) async {
    savedEntries = entries;
    _entries = entries;
    return const Right(null);
  }
}

ScheduleEntryEntity _entry({
  required String id,
  int weekday = DateTime.monday,
  String title = "Math",
}) => ScheduleEntryEntity(
  id: id,
  title: title,
  weekday: weekday,
  startMinutes: 8 * 60,
  endMinutes: 9 * 60,
  colorValue: 1,
  activeFrom: DateTime(2026, 1, 1),
);

void main() {
  group("UpdateScheduleEntryUseCase", () {
    test("edits every equal occurrence across weekdays", () async {
      final repository = _FakeScheduleRepository([
        _entry(id: "a", weekday: DateTime.monday),
        _entry(id: "b", weekday: DateTime.tuesday),
      ]);
      final useCase = UpdateScheduleEntryUseCase(
        scheduleRepository: repository,
      );

      final result = await useCase(
        entryId: "a",
        title: "Physics",
        weekdays: const [DateTime.wednesday],
        startMinutes: 10 * 60,
        endMinutes: 11 * 60,
        colorValue: 42,
        activeFrom: DateTime(2026, 2, 1),
        activeUntil: null,
      );

      final entries = result.getOrElse(() => []);
      expect(entries.length, 1);
      final ScheduleEntryEntity edited = entries.firstWhere((e) => e.id == "a");
      expect(edited.title, "Physics");
      expect(edited.weekday, DateTime.wednesday);
      expect(edited.colorValue, 42);
      expect(entries.any((e) => e.id == "b"), isFalse);
    });

    test(
      "spreads extra weekdays into new entries keeping the original id",
      () async {
        final repository = _FakeScheduleRepository([
          _entry(id: "a", weekday: DateTime.monday),
        ]);
        final useCase = UpdateScheduleEntryUseCase(
          scheduleRepository: repository,
        );

        final result = await useCase(
          entryId: "a",
          title: "Gym",
          weekdays: const [
            DateTime.monday,
            DateTime.wednesday,
            DateTime.friday,
          ],
          startMinutes: null,
          endMinutes: null,
          colorValue: 7,
          activeFrom: DateTime(2026, 1, 1),
          activeUntil: null,
        );

        final entries = result.getOrElse(() => []);
        expect(entries.length, 3);
        expect(entries.where((e) => e.id == "a").length, 1);
        expect(entries.map((e) => e.weekday).toSet(), {
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday,
        });
        expect(entries.every((e) => e.title == "Gym"), isTrue);
      },
    );

    test("does not edit a different series", () async {
      final repository = _FakeScheduleRepository([
        _entry(id: "a", weekday: DateTime.monday),
        _entry(id: "b", weekday: DateTime.tuesday, title: "Physics"),
      ]);
      final useCase = UpdateScheduleEntryUseCase(
        scheduleRepository: repository,
      );

      final result = await useCase(
        entryId: "a",
        title: "Gym",
        weekdays: const [DateTime.wednesday],
        startMinutes: null,
        endMinutes: null,
        colorValue: 7,
        activeFrom: DateTime(2026, 1, 1),
        activeUntil: null,
      );

      final entries = result.getOrElse(() => []);
      expect(entries.length, 2);
      expect(entries.any((e) => e.id == "b" && e.title == "Physics"), isTrue);
    });

    test("fails when no weekday is provided", () async {
      final repository = _FakeScheduleRepository([_entry(id: "a")]);
      final useCase = UpdateScheduleEntryUseCase(
        scheduleRepository: repository,
      );

      final result = await useCase(
        entryId: "a",
        title: "X",
        weekdays: const [],
        startMinutes: null,
        endMinutes: null,
        colorValue: 1,
        activeFrom: DateTime(2026, 1, 1),
        activeUntil: null,
      );

      expect(result.isLeft(), isTrue);
      expect(repository.savedEntries, isNull);
    });
  });
}

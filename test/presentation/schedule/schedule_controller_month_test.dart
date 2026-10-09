import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:timing/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:timing/core/domain/use_cases/update_schedule_entry_use_case.dart";
import "package:timing/presentation/schedule/add_schedule_entry_page.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";

class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NoEntries extends _Unused implements ScheduleRepository {
  @override
  Future<Either<AppError, List<ScheduleEntryEntity>>> getEntries() async =>
      const Right([]);
}

class _UnusedAdd extends _Unused implements AddScheduleEntryUseCase {}

class _UnusedDelete extends _Unused implements DeleteScheduleEntryUseCase {}

class _UnusedUpdate extends _Unused implements UpdateScheduleEntryUseCase {}

class _UnusedNavigator extends _Unused implements AppNavigator {}

class _CapturingNavigator extends _Unused implements AppNavigator {
  Object? capturedArguments;

  @override
  Future<T?>? toNamed<T>(
    String page, {
    Object? arguments,
    int? id,
    bool preventDuplicates = true,
  }) async {
    capturedArguments = arguments;
    return null;
  }
}

ScheduleController _controller({AppNavigator? navigator}) => ScheduleController(
  scheduleRepository: _NoEntries(),
  addScheduleEntryUseCase: _UnusedAdd(),
  deleteScheduleEntryUseCase: _UnusedDelete(),
  updateScheduleEntryUseCase: _UnusedUpdate(),
  appNavigator: navigator ?? _UnusedNavigator(),
);

ScheduleEntryEntity _entry({required String id, required int weekday}) =>
    ScheduleEntryEntity(
      id: id,
      title: "Gym",
      weekday: weekday,
      startMinutes: 8 * 60,
      endMinutes: 9 * 60,
      colorValue: 1,
      activeFrom: DateTime(2026, 1, 1),
    );

void main() {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime thisMonth = DateTime(now.year, now.month);

  test("starts on today, showing this month", () {
    final ScheduleController controller = _controller();

    expect(controller.selectedDate.value, today);
    expect(controller.visibleMonth.value, thisMonth);
  });

  test("paging months never moves the selected day", () {
    final ScheduleController controller = _controller();

    controller.onChangeMonth(1);
    controller.onChangeMonth(1);
    controller.onChangeMonth(-3);

    expect(controller.visibleMonth.value, DateTime(now.year, now.month - 1));
    expect(controller.selectedDate.value, today);
  });

  test("picking a month and year only changes the month on screen", () {
    final ScheduleController controller = _controller();

    controller.onSelectMonth(2031, 2);

    expect(controller.visibleMonth.value, DateTime(2031, 2));
    expect(controller.selectedDate.value, today);
  });

  test("paging across a year boundary lands on the right month", () {
    final ScheduleController controller = _controller();
    controller.onSelectMonth(2026, 12);

    controller.onChangeMonth(1);

    expect(controller.visibleMonth.value, DateTime(2027));
  });

  test("selecting a day also brings its month on screen", () {
    final ScheduleController controller = _controller();
    controller.onChangeMonth(4);

    controller.onSelectDate(DateTime(2031, 8, 9, 15, 30));

    expect(controller.selectedDate.value, DateTime(2031, 8, 9));
    expect(controller.visibleMonth.value, DateTime(2031, 8));
  });

  test(
    "editing an occurrence opens every weekday in the same series",
    () async {
      final navigator = _CapturingNavigator();
      final ScheduleController controller = _controller(navigator: navigator);
      final monday = _entry(id: "a", weekday: DateTime.monday);
      controller.entries.value = [
        monday,
        _entry(id: "b", weekday: DateTime.wednesday),
        _entry(id: "c", weekday: DateTime.friday),
      ];

      await controller.onEditEntry(monday);

      final arguments =
          navigator.capturedArguments as ScheduleEntryEditArguments;
      expect(arguments.entry, monday);
      expect(arguments.weekdays, [
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
      ]);
    },
  );
}

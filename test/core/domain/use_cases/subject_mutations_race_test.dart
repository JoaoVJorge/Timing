import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// Storage whose reads and writes yield to the event loop, so two overlapping
/// read-modify-write mutations really interleave.
class _SlowStorage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> data = {};

  @override
  Future<T?> read<T>(LocalStorageKeys key) async {
    await Future<void>.delayed(Duration.zero);
    return data[key] as T?;
  }

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    await Future<void>.delayed(Duration.zero);
    data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SignedOutSupabase implements SupabaseService {
  @override
  String? get currentUserId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const SubjectEntity _book = SubjectEntity(
  id: "book",
  name: "Livro",
  category: TimeCategoryType.reading,
  colorValue: 0xFF000000,
  totalSeconds: 0,
  goalSeconds: 0,
  currentPages: 0,
  goalPages: 100,
  notes: "",
  iconName: "",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
);

Future<SubjectsRepository> _repository(_SlowStorage storage) async {
  storage.data[LocalStorageKeys.subjects] = jsonEncode([_book.toMap()]);
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  return SubjectsRepository(
    subjectsDataSource: SubjectsDataSource(
      localStorageService: storage,
      supabaseService: _SignedOutSupabase(),
      logger: AppLoggerService(),
      pendingSyncStore: store,
    ),
  );
}

Future<SubjectEntity> _stored(SubjectsRepository repository) async {
  final result = await repository.getSubjects();
  return result.fold((_) => fail("expected Right"), (list) => list.single);
}

void main() {
  test(
    "finishing a reading session keeps both the seconds and the pages",
    () async {
      final repository = await _repository(_SlowStorage());
      // The timer's flush (seconds) and finishReadingSession (pages) start
      // together, exactly as in TimerController.finishReadingSession.
      final time = UpdateSubjectTimeUseCase(subjectsRepository: repository);
      final pages = UpdateSubjectPagesUseCase(subjectsRepository: repository);

      await Future.wait([
        time(subjectId: "book", totalSeconds: 600),
        pages(subjectId: "book", currentPages: 25),
      ]);

      final subject = await _stored(repository);
      expect(subject.totalSeconds, 600);
      expect(subject.currentPages, 25);
    },
  );

  test("a notes edit does not overwrite a concurrent time update", () async {
    final repository = await _repository(_SlowStorage());
    final time = UpdateSubjectTimeUseCase(subjectsRepository: repository);
    final notes = UpdateSubjectNotesUseCase(subjectsRepository: repository);

    await Future.wait([
      time(subjectId: "book", totalSeconds: 300),
      notes(subjectId: "book", notes: "capítulo 3"),
    ]);

    final subject = await _stored(repository);
    expect(subject.totalSeconds, 300);
    expect(subject.notes, "capítulo 3");
  });
}

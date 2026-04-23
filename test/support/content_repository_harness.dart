import 'package:drift/native.dart';
import 'package:memox/core/services/clock.dart';
import 'package:memox/core/services/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/deck_repository_impl.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/repositories/deck_repository.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/services/folder_structure_service.dart';

final class TestClock implements Clock {
  TestClock(this._current);

  DateTime _current;

  @override
  DateTime nowUtc() => _current;

  @override
  int nowEpochMillis() => _current.millisecondsSinceEpoch;

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}

final class SequenceIdGenerator implements IdGenerator {
  SequenceIdGenerator([Iterable<String>? seeds])
    : _queue = List<String>.from(seeds ?? const <String>[]);

  final List<String> _queue;
  var _counter = 0;

  @override
  String nextId() {
    if (_queue.isNotEmpty) {
      return _queue.removeAt(0);
    }
    final value = 'id-${_counter.toString().padLeft(4, '0')}';
    _counter += 1;
    return value;
  }
}

final class ContentRepositoryHarness {
  ContentRepositoryHarness._({
    required this.database,
    required this.clock,
    required this.idGenerator,
    required this.folderRepository,
    required this.deckRepository,
    required this.flashcardRepository,
  });

  factory ContentRepositoryHarness.create({
    DateTime? now,
    Iterable<String>? ids,
  }) {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final clock = TestClock(now ?? DateTime.utc(2026, 4, 23, 9));
    final idGenerator = SequenceIdGenerator(ids);
    final transactionRunner = LocalTransactionRunner(database);
    final folderDao = FolderDao(database);
    final deckDao = DeckDao(database);
    final flashcardDao = FlashcardDao(database);
    const structureService = FolderStructureService();

    return ContentRepositoryHarness._(
      database: database,
      clock: clock,
      idGenerator: idGenerator,
      folderRepository: FolderRepositoryImpl(
        folderDao: folderDao,
        deckDao: deckDao,
        transactionRunner: transactionRunner,
        structureService: structureService,
        clock: clock,
        idGenerator: idGenerator,
      ),
      deckRepository: DeckRepositoryImpl(
        deckDao: deckDao,
        flashcardDao: flashcardDao,
        folderDao: folderDao,
        transactionRunner: transactionRunner,
        structureService: structureService,
        clock: clock,
        idGenerator: idGenerator,
      ),
      flashcardRepository: FlashcardRepositoryImpl(
        flashcardDao: flashcardDao,
        deckDao: deckDao,
        folderDao: folderDao,
        transactionRunner: transactionRunner,
        clock: clock,
        idGenerator: idGenerator,
      ),
    );
  }

  final AppDatabase database;
  final TestClock clock;
  final SequenceIdGenerator idGenerator;
  final FolderRepository folderRepository;
  final DeckRepository deckRepository;
  final FlashcardRepository flashcardRepository;

  Future<void> dispose() => database.close();
}

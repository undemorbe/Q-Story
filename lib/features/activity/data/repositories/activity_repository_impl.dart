import 'package:sembast/sembast.dart';

import '../../../../core/storage/app_database.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(AppDatabase database) : _database = database;

  final AppDatabase _database;
  Database get _db => _database.db;

  @override
  Future<bool> addVisit(Visit visit) async {
    final rec = AppDatabase.visits.record(visit.placeId);
    if (await rec.exists(_db)) return false;
    await rec.put(_db, visit.toJson());
    return true;
  }

  @override
  Future<List<Visit>> visits() async {
    final recs = await AppDatabase.visits.find(_db, finder: Finder(sortOrders: [SortOrder('at', false)]));
    return recs.map((r) => Visit.fromJson(r.value)).toList();
  }

  @override
  Future<Set<String>> visitedIds() async => (await AppDatabase.visits.findKeys(_db)).toSet();

  @override
  Future<void> saveHunt(Hunt hunt) => AppDatabase.hunts.record(hunt.id).put(_db, hunt.toJson());

  @override
  Future<List<Hunt>> hunts() async {
    final recs = await AppDatabase.hunts.find(_db, finder: Finder(sortOrders: [SortOrder('startedAt', false)]));
    return recs.map((r) => Hunt.fromJson(r.value)).toList();
  }

  @override
  Future<Hunt?> activeHunt() async {
    final rec = await AppDatabase.hunts.findFirst(
      _db,
      finder: Finder(filter: Filter.equals('status', HuntStatus.active.name)),
    );
    return rec == null ? null : Hunt.fromJson(rec.value);
  }

  @override
  Future<DayActivity> day(String dayKey) async {
    final rec = await AppDatabase.days.record(dayKey).get(_db);
    return rec == null ? DayActivity(day: dayKey) : DayActivity.fromJson(rec);
  }

  @override
  Future<void> saveDay(DayActivity day) => AppDatabase.days.record(day.day).put(_db, day.toJson());

  @override
  Future<List<DayActivity>> days() async {
    final recs = await AppDatabase.days.find(_db, finder: Finder(sortOrders: [SortOrder(Field.key)]));
    return recs.map((r) => DayActivity.fromJson(r.value)).toList();
  }

  @override
  Future<bool> addExploredCell(String cellKey) async {
    final rec = AppDatabase.cells.record(cellKey);
    if (await rec.exists(_db)) return false;
    await rec.put(_db, {'at': DateTime.now().millisecondsSinceEpoch});
    return true;
  }

  @override
  Future<int> exploredCellCount() => AppDatabase.cells.count(_db);

  @override
  Future<void> log(ActivityEvent event) => AppDatabase.events.add(_db, event.toJson());

  @override
  Future<List<ActivityEvent>> events() async {
    final recs = await AppDatabase.events.find(_db);
    return recs.map((r) => ActivityEvent.fromJson(r.value)).toList();
  }

  @override
  Future<void> clearAll() => _database.clearStatistics();
}

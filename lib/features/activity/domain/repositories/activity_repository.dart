import '../entities/activity.dart';

/// Local-only store of everything the statistics page is built from.
abstract interface class ActivityRepository {
  // Visits
  Future<bool> addVisit(Visit visit);
  Future<List<Visit>> visits();
  Future<Set<String>> visitedIds();

  // Hunts
  Future<void> saveHunt(Hunt hunt);
  Future<List<Hunt>> hunts();
  Future<Hunt?> activeHunt();

  // Movement
  Future<DayActivity> day(String dayKey);
  Future<void> saveDay(DayActivity day);
  Future<List<DayActivity>> days();
  Future<bool> addExploredCell(String cellKey);
  Future<int> exploredCellCount();

  // Events
  Future<void> log(ActivityEvent event);
  Future<List<ActivityEvent>> events();

  Future<void> clearAll();
}

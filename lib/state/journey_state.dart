import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks progress through the three chapters. The finale ("The
/// Surprise" node on the hub) unlocks once all three are true.
/// Completed chapters are persisted so she never loses progress if
/// the app is closed; "replay the journey" clears them again.
class JourneyState extends ChangeNotifier {
  static const _kGarden = 'chapter.gardenVisited';
  static const _kTreehouse = 'chapter.treehouseVisited';
  static const _kStarryHill = 'chapter.starryHillVisited';

  bool gardenVisited = false;
  bool treehouseVisited = false;
  bool starryHillVisited = false;

  JourneyState() {
    _load();
  }

  bool get allChaptersDone =>
      gardenVisited && treehouseVisited && starryHillVisited;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;
    if (prefs.getBool(_kGarden) ?? false) {
      gardenVisited = true;
      changed = true;
    }
    if (prefs.getBool(_kTreehouse) ?? false) {
      treehouseVisited = true;
      changed = true;
    }
    if (prefs.getBool(_kStarryHill) ?? false) {
      starryHillVisited = true;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGarden, gardenVisited);
    await prefs.setBool(_kTreehouse, treehouseVisited);
    await prefs.setBool(_kStarryHill, starryHillVisited);
  }

  void completeGarden() {
    if (!gardenVisited) {
      gardenVisited = true;
      notifyListeners();
      _save();
    }
  }

  void completeTreehouse() {
    if (!treehouseVisited) {
      treehouseVisited = true;
      notifyListeners();
      _save();
    }
  }

  void completeStarryHill() {
    if (!starryHillVisited) {
      starryHillVisited = true;
      notifyListeners();
      _save();
    }
  }

  Future<void> reset() async {
    gardenVisited = false;
    treehouseVisited = false;
    starryHillVisited = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGarden);
    await prefs.remove(_kTreehouse);
    await prefs.remove(_kStarryHill);
  }
}

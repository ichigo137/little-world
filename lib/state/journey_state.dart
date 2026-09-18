import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks progress through the three chapters. The finale ("The
/// Surprise" node on the hub) unlocks once all three are true.
/// Completed chapters are persisted so she never loses progress if
/// the app is closed; "replay the journey" clears them again.
///
/// Partial in-chapter progress (which flowers are bloomed, which
/// windows are lit) is also persisted so navigating back to the hub
/// and re-entering a chapter does not reset progress.
class JourneyState extends ChangeNotifier {
  static const _kGarden = 'chapter.gardenVisited';
  static const _kTreehouse = 'chapter.treehouseVisited';
  static const _kStarryHill = 'chapter.starryHillVisited';
  static const _kGardenBloomed = 'chapter.gardenBloomed';
  static const _kTreehouseLit = 'chapter.treehouseLit';

  bool gardenVisited = false;
  bool treehouseVisited = false;
  bool starryHillVisited = false;

  /// Per-flower bloom state for the Garden. null until first loaded.
  List<bool>? gardenBloomed;

  /// Per-window lit state for the Treehouse. null until first loaded.
  List<bool>? treehouseLit;

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
    final bloomJson = prefs.getString(_kGardenBloomed);
    if (bloomJson != null) {
      try {
        final list = jsonDecode(bloomJson) as List;
        gardenBloomed = list.map((e) => e as bool).toList();
        changed = true;
      } catch (_) {}
    }
    final litJson = prefs.getString(_kTreehouseLit);
    if (litJson != null) {
      try {
        final list = jsonDecode(litJson) as List;
        treehouseLit = list.map((e) => e as bool).toList();
        changed = true;
      } catch (_) {}
    }
    if (changed) notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGarden, gardenVisited);
    await prefs.setBool(_kTreehouse, treehouseVisited);
    await prefs.setBool(_kStarryHill, starryHillVisited);
    if (gardenBloomed != null) {
      await prefs.setString(_kGardenBloomed, jsonEncode(gardenBloomed));
    }
    if (treehouseLit != null) {
      await prefs.setString(_kTreehouseLit, jsonEncode(treehouseLit));
    }
  }

  /// Ensure the bloom list is the right length and return it.
  List<bool> getOrInitGardenBloomed(int length) {
    if (gardenBloomed == null || gardenBloomed!.length != length) {
      gardenBloomed = List.filled(length, false);
    }
    return gardenBloomed!;
  }

  /// Ensure the lit list is the right length and return it.
  List<bool> getOrInitTreehouseLit(int length) {
    if (treehouseLit == null || treehouseLit!.length != length) {
      treehouseLit = List.filled(length, false);
    }
    return treehouseLit!;
  }

  /// Mark a single flower as bloomed and persist.
  void bloomFlower(int index) {
    final list = gardenBloomed;
    if (list == null || index < 0 || index >= list.length) return;
    if (list[index]) return;
    list[index] = true;
    if (list.every((b) => b)) {
      gardenVisited = true;
    }
    notifyListeners();
    _save();
  }

  /// Mark a single window as lit and persist.
  void lightWindow(int index) {
    final list = treehouseLit;
    if (list == null || index < 0 || index >= list.length) return;
    if (list[index]) return;
    list[index] = true;
    if (list.every((b) => b)) {
      treehouseVisited = true;
    }
    notifyListeners();
    _save();
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
    gardenBloomed = null;
    treehouseLit = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGarden);
    await prefs.remove(_kTreehouse);
    await prefs.remove(_kStarryHill);
    await prefs.remove(_kGardenBloomed);
    await prefs.remove(_kTreehouseLit);
  }
}

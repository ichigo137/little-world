import 'package:flutter/foundation.dart';

/// Tracks progress through the three chapters. The finale ("The
/// Surprise" node on the hub) unlocks once all three are true.
class JourneyState extends ChangeNotifier {
  bool gardenVisited = false;
  bool treehouseVisited = false;
  bool starryHillVisited = false;

  bool get allChaptersDone =>
      gardenVisited && treehouseVisited && starryHillVisited;

  void completeGarden() {
    if (!gardenVisited) {
      gardenVisited = true;
      notifyListeners();
    }
  }

  void completeTreehouse() {
    if (!treehouseVisited) {
      treehouseVisited = true;
      notifyListeners();
    }
  }

  void completeStarryHill() {
    if (!starryHillVisited) {
      starryHillVisited = true;
      notifyListeners();
    }
  }

  void reset() {
    gardenVisited = false;
    treehouseVisited = false;
    starryHillVisited = false;
    notifyListeners();
  }
}

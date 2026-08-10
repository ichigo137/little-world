/// A single memory: a short message with an optional photo.
class MemoryItem {
  final String message;
  final String? photoAsset;
  const MemoryItem({required this.message, this.photoAsset});
}

/// ============================================================
///   EDIT ME — this is the ONLY file you need to touch to make
///   the app yours. Change the text, drop photos into
///   assets/photos/, then point photoAsset at the filename.
///   e.g. photoAsset: 'assets/photos/us_at_the_beach.jpg'
/// ============================================================
class AppContent {
  // Shown on the very first screen and on the finale card.
  static const String herName = 'Put Her Name Here';

  // Small line under her name on the gift screen.
  static const String heroTagline = 'a tiny world I built, just for you';

  // ---------------- THE GARDEN ----------------
  // 5-6 short, punchy memories. Tapping a flower blooms it and
  // shows one of these. Photos are optional here — text hits fine.
  static const List<MemoryItem> gardenMemories = [
    MemoryItem(
        message:
            'The first time we talked, I knew this year would be different.'),
    MemoryItem(
        message:
            'That random Tuesday we laughed for two hours straight over nothing.'),
    MemoryItem(message: 'The way you say my name right before you roast me.'),
    MemoryItem(
        message: 'Every playlist you\'ve ever sent me — still on repeat.'),
    MemoryItem(
        message: 'The dumb inside joke only the two of us will ever get.'),
    MemoryItem(message: 'You, in general. That\'s the memory.'),
  ];

  // ---------------- THE TREEHOUSE ----------------
  // 4-5 windows, each meant to hold a real photo + caption.
  // Replace photoAsset: null with the path once you've added images.
  static const List<MemoryItem> treehouseMemories = [
    MemoryItem(message: 'Write a caption for this photo...', photoAsset: null),
    MemoryItem(message: 'Write a caption for this photo...', photoAsset: null),
    MemoryItem(message: 'Write a caption for this photo...', photoAsset: null),
    MemoryItem(message: 'Write a caption for this photo...', photoAsset: null),
    MemoryItem(message: 'Write a caption for this photo...', photoAsset: null),
  ];

  // ---------------- STARRY HILL ----------------
  // One longer message, revealed after she connects every star
  // into a heart and a shooting star crosses the sky.
  static const String constellationMessage =
      'Every star up there is a reason I\'m glad you exist. '
      'I could map out a hundred more skies and still not run out.';

  // ---------------- THE SECRET LINK ----------------
  // A live site hidden inside the QR code on the final screen.
  // Point it at whatever surprise lives online for her.
  static const String secretLinkUrl =
      'https://secret-site-for-birt.onrender.com';

  // ---------------- THE FINALE ----------------
  static const String finaleTitle = 'Happy Birthday';

  static const String finaleMessage =
      'Happy birthday to the person who makes ordinary days feel like '
      'plot twists in the best way. I hope this year hands you everything '
      'you deserve, and then a little more, just because.\n\n'
      'I love you. Now go eat some real cake.';
}

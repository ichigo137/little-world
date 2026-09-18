import 'package:audioplayers/audioplayers.dart';

/// Tiny central place for all sound effects. Chimes are short, soft
/// and fire-and-forget; a quiet ambient pad loops in the background
/// once the journey has begun. Every call is guarded so a missing
/// asset or an unsupported platform just stays silent.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _ambient = AudioPlayer();
  bool _ambientStarted = false;

  Future<void> play(String asset) async {
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource(asset));
    } catch (_) {
      // Ignore — silence is fine on platforms without audio.
    }
  }

  Future<void> startAmbient() async {
    if (_ambientStarted) return;
    _ambientStarted = true;
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.10);
      await _ambient.play(AssetSource('audio/ambient.wav'));
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> stopAmbient() async {
    _ambientStarted = false;
    try {
      await _ambient.stop();
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> dispose() async {
    _ambientStarted = false;
    try {
      await _sfx.dispose();
      await _ambient.dispose();
    } catch (_) {
      // Ignore.
    }
  }
}

/// Convenience names so screens read nicely.
class Sfx {
  static const bloom = 'audio/bloom.wav';
  static const window = 'audio/window.wav';
  static const star = 'audio/star.wav';
  static const complete = 'audio/complete.wav';
  static const candle = 'audio/candle.wav';
}
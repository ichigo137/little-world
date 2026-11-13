import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Tiny central place for all sound effects. Chimes are short, soft
/// and fire-and-forget; a quiet ambient pad loops in the background
/// once the journey has begun. Every call is guarded so a missing
/// asset or an unsupported platform just stays silent.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _ambient = AudioPlayer();
  final ValueNotifier<bool> muted = ValueNotifier<bool>(false);
  bool _ambientStarted = false;
  bool _ambientPaused = false;

  bool _ambientWanted = false;

  bool get isMuted => muted.value;

  Future<void> toggleMute() => setMuted(!muted.value);

  Future<void> setMuted(bool value) async {
    if (muted.value == value) return;
    muted.value = value;
    try {
      if (value) {
        await _sfx.stop();
        if (_ambientStarted) {
          await _ambient.pause();
        }
      } else if (_ambientWanted && !_ambientPaused) {
        await resumeAmbient();
      }
    } catch (_) {
      // Ignore on platforms without audio support.
    }
  }

  Future<void> play(String asset) async {
    if (muted.value) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource(asset));
    } catch (_) {
      // Ignore — silence is fine on platforms without audio.
    }
  }

  Future<void> startAmbient() async {
    _ambientWanted = true;
    _ambientPaused = false;
    if (_ambientStarted) return;
    _ambientStarted = true;
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.10);
      if (!muted.value) {
        await _ambient.play(AssetSource('audio/ambient.wav'));
      }
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> pauseAmbient() async {
    _ambientPaused = true;
    try {
      await _ambient.pause();
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> resumeAmbient() async {
    _ambientPaused = false;
    if (!_ambientWanted || muted.value) return;
    try {
      if (!_ambientStarted) {
        _ambientStarted = true;
        await _ambient.setReleaseMode(ReleaseMode.loop);
        await _ambient.setVolume(0.10);
        await _ambient.play(AssetSource('audio/ambient.wav'));
      } else if (_ambient.state == PlayerState.paused) {
        await _ambient.resume();
      } else if (_ambient.state != PlayerState.playing) {
        await _ambient.setReleaseMode(ReleaseMode.loop);
        await _ambient.setVolume(0.10);
        await _ambient.play(AssetSource('audio/ambient.wav'));
      }
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> stopAmbient() async {
    _ambientWanted = false;
    _ambientStarted = false;
    _ambientPaused = false;
    try {
      await _ambient.stop();
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> dispose() async {
    _ambientWanted = false;
    _ambientStarted = false;
    _ambientPaused = false;
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
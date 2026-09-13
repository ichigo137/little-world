import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../content.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/section_header.dart';

/// A small Spotify-flavoured player for the finale: cover art header,
/// a numbered track list, and a bottom bar with seek, play/pause,
/// previous/next, shuffle and repeat. Plays the songs bundled in
/// AppContent.finalePlaylist straight inside the app.
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final AudioPlayer _player = AudioPlayer();
  final math.Random _random = math.Random();

  int _index = 0;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _shuffle = false;
  bool _repeat = true;

  List<PlaylistTrack> get _tracks => AppContent.finalePlaylist;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) _next(autoSkip: true);
    });
    if (_tracks.isNotEmpty) {
      _load(0);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load(int index) async {
    if (_tracks.isEmpty) return;
    final safe = index.clamp(0, _tracks.length - 1);
    setState(() {
      _index = safe;
      _position = Duration.zero;
      _duration = _tracks[safe].duration ?? Duration.zero;
    });
    final track = _tracks[safe];
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource(track.audioAsset));
    } catch (_) {
      // Missing/corrupt asset (or audio unavailable in this context).
      // Land on the track but stay paused instead of retrying forever.
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'couldn\u2019t play that track',
            style: GoogleFonts.comfortaa(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.nightSoft,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  int _nextIndex() {
    if (_tracks.isEmpty) return _index;
    if (_shuffle) return _random.nextInt(_tracks.length);
    if (_repeat) return (_index + 1) % _tracks.length;
    return math.min(_index + 1, _tracks.length - 1);
  }

  void _next({bool autoSkip = false}) {
    if (_tracks.isEmpty) return;
    if (!autoSkip || _repeat || _shuffle) {
      _load(_nextIndex());
    } else if (_index < _tracks.length - 1) {
      _load(_index + 1);
    } else {
      setState(() => _playing = false);
    }
  }

  void _previous() {
    if (_tracks.isEmpty) return;
    if (_position > const Duration(seconds: 3)) {
      _player.seek(Duration.zero);
      return;
    }
    final i = _shuffle
        ? _random.nextInt(_tracks.length)
        : (_index - 1 + _tracks.length) % _tracks.length;
    _load(i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightRose,
        showClouds: true,
        child: SafeArea(
          child: Column(
            children: [
              const SectionHeader(
                title: 'the soundtrack of us',
                subtitle: 'a little playlist, just for you',
              ),
              if (_tracks.isEmpty)
                const Expanded(child: _EmptyPlaylist())
              else ...[
                _NowPlayingHeader(
                  track: _tracks[_index],
                  playing: _playing,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _tracks.length,
                    itemBuilder: (context, i) {
                      return _TrackTile(
                        track: _tracks[i],
                        index: i,
                        active: i == _index,
                        playing: i == _index && _playing,
                        onTap: () => _load(i),
                      );
                    },
                  ),
                ),
                _PlayerBar(
                  position: _position,
                  duration: _duration,
                  playing: _playing,
                  shuffle: _shuffle,
                  repeat: _repeat,
                  onShuffle: () => setState(() => _shuffle = !_shuffle),
                  onRepeat: () => setState(() => _repeat = !_repeat),
                  onPrev: _previous,
                  onPlay: _togglePlay,
                  onNext: _next,
                  onSeek: (millis) => _player.seek(Duration(milliseconds: millis)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingHeader extends StatelessWidget {
  final PlaylistTrack track;
  final bool playing;

  const _NowPlayingHeader({required this.track, required this.playing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: Row(
        children: [
          _Artwork(track: track, size: 96),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.caveat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.comfortaa(
                    fontSize: 12,
                    color: AppTheme.textSoft,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (playing)
                      const _Equalizer()
                    else
                      const Icon(
                        Icons.music_note_rounded,
                        color: AppTheme.textSoft,
                        size: 18,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      playing ? 'now playing' : 'paused',
                      style: GoogleFonts.comfortaa(
                        fontSize: 11,
                        color: playing ? AppTheme.mint : AppTheme.textSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final PlaylistTrack track;
  final int index;
  final bool active;
  final bool playing;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.index,
    required this.active,
    required this.playing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final number = index + 1;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.nightSoft.withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.45),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: playing
                  ? const _Equalizer(tall: true)
                  : Text(
                      number.toString().padLeft(2, '0'),
                      style: GoogleFonts.comfortaa(
                        fontSize: 12,
                        color: active ? AppTheme.gold : AppTheme.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.comfortaa(
                      fontSize: 14,
                      color: active ? AppTheme.textLight : AppTheme.textSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    track.artist,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.comfortaa(
                      fontSize: 11,
                      color: AppTheme.textSoft.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (track.duration != null)
              Text(
                _fmtTrack(track.duration!),
                style: GoogleFonts.comfortaa(
                  fontSize: 11,
                  color: AppTheme.textSoft,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmtTrack(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _PlayerBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool playing;
  final bool shuffle;
  final bool repeat;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onPrev;
  final VoidCallback onPlay;
  final VoidCallback onNext;
  final ValueChanged<int> onSeek;

  const _PlayerBar({
    required this.position,
    required this.duration,
    required this.playing,
    required this.shuffle,
    required this.repeat,
    required this.onShuffle,
    required this.onRepeat,
    required this.onPrev,
    required this.onPlay,
    required this.onNext,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = math.max(1, duration.inMilliseconds);
    final value = position.inMilliseconds.clamp(0, maxMs).toDouble();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.nightSoft.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _fmt(position),
                style: GoogleFonts.comfortaa(
                    fontSize: 11, color: AppTheme.textSoft),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: AppTheme.gold,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                    thumbColor: AppTheme.gold,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: value,
                    max: maxMs.toDouble(),
                    onChanged: (_) {},
                    onChangeEnd: (v) => onSeek(v.round()),
                  ),
                ),
              ),
              Text(
                _fmt(duration),
                style: GoogleFonts.comfortaa(
                    fontSize: 11, color: AppTheme.textSoft),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onShuffle,
                icon: Icon(
                  Icons.shuffle_rounded,
                  size: 20,
                  color: shuffle ? AppTheme.mint : AppTheme.textSoft,
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                onPressed: onPrev,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: AppTheme.textLight,
                  size: 34,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.blush,
                  ),
                  child: Icon(
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppTheme.textDark,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onNext,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppTheme.textLight,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                onPressed: onRepeat,
                icon: Icon(
                  repeat ? Icons.repeat_rounded : Icons.repeat_one_rounded,
                  size: 20,
                  color: repeat ? AppTheme.mint : AppTheme.textSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _Artwork extends StatelessWidget {
  final PlaylistTrack track;
  final double size;

  const _Artwork({required this.track, required this.size});

  @override
  Widget build(BuildContext context) {
    if (track.coverAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          track.coverAsset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.lavender, AppTheme.gold],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.45,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _Equalizer extends StatelessWidget {
  final bool tall;

  const _Equalizer({this.tall = false});

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.mint;
    return SizedBox(
      width: 20,
      height: tall ? 20 : 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in [0.5, 1.0, 0.7])
            Container(
              width: 3,
              height: 16 * h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPlaylist extends StatelessWidget {
  const _EmptyPlaylist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.queue_music_rounded,
              color: AppTheme.textSoft,
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              'the playlist hasn\u2019t been filled yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.comfortaa(
                fontSize: 13,
                color: AppTheme.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
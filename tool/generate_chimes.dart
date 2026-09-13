// Generates the placeholder sound assets in assets/audio/ as 16-bit
// mono PCM WAVs using pure additive synthesis — no external files or
// dependencies needed. Run once with:  dart run tool/generate_chimes.dart
//
// The sounds are intentionally soft and gentle to match the app's
// mood. To use real audio instead, drop your own .wav/.mp3 files into
// assets/audio/ with the same names and delete the generated ones.
import 'dart:io';
import 'dart:math' as math;

const double _sr = 22050;

void main() {
  final outDir = Directory('assets/audio');
  outDir.createSync(recursive: true);

  final bloom = _buildAsBars([
    _note(659.25, 0.0, 0.9, 0.25),
    _note(523.25, 0.12, 0.8, 0.35),
    _note(783.99, 0.24, 0.55, 0.4),
  ]);
  _writeWav(outDir, 'bloom.wav', bloom);

  final window = _buildAsBars([
    _note(987.77, 0.0, 0.7, 0.12),
    _note(1318.51, 0.06, 0.4, 0.2),
  ]);
  _writeWav(outDir, 'window.wav', window);

  final star = _buildAsBars([
    _note(1318.51, 0.0, 0.6, 0.1),
    _note(1975.53, 0.05, 0.25, 0.18),
  ]);
  _writeWav(outDir, 'star.wav', star);

  final complete = _buildAsBars([
    _note(523.25, 0.00, 0.8, 0.14),
    _note(659.25, 0.10, 0.8, 0.14),
    _note(783.99, 0.20, 0.8, 0.14),
    _note(1046.50, 0.30, 0.95, 0.45),
  ]);
  _writeWav(outDir, 'complete.wav', complete);

  final candle = _buildCandleWav();
  _writeWav(outDir, 'candle.wav', candle);

  final ambient = _buildAmbient();
  _writeWav(outDir, 'ambient.wav', ambient);

  stdout.writeln('Generated chimes in ${outDir.path}: '
      'bloom, window, star, complete, candle, ambient');
}

class _Bar {
  final List<double> samples;
  final double offsetSec;
  _Bar(this.samples, this.offsetSec);
}

_Bar _note(double freq, double delay, double amp, double decaySec) {
  const totalSec = 0.8;
  final n = (_sr * totalSec).floor();
  final out = List<double>.filled(n, 0);
  final start = (delay * _sr).floor();
  for (int i = 0; i < n; i++) {
    final t = i / _sr;
    final env = math.exp(-i / (decaySec * _sr));
    var s = math.sin(2 * math.pi * freq * t) * env;
    s += 0.35 * math.sin(2 * math.pi * freq * 2 * t) * env;
    s *= amp * 0.5;
    final idx = start + i;
    if (idx < out.length) out[idx] += s;
  }
  return _Bar(out, 0);
}

List<double> _buildAsBars(List<_Bar> bars) {
  const length = _sr * 1.6;
  final out = List<double>.filled(length.floor(), 0);
  for (final bar in bars) {
    final start = (bar.offsetSec * _sr).floor();
    for (int i = 0; i < bar.samples.length && start + i < out.length; i++) {
      out[start + i] += bar.samples[i];
    }
  }
  return _normalize(out);
}

List<double> _buildCandleWav() {
  final n = (_sr * 0.6).floor();
  final out = List<double>.filled(n, 0);
  final rng = math.Random(7);
  final puffN = (_sr * 0.22).floor();
  var last = 0.0;
  for (int i = 0; i < puffN; i++) {
    final raw = rng.nextDouble() * 2 - 1;
    last = last * 0.72 + raw * 0.28;
    final env = math.exp(-3.2 * i / puffN);
    out[i] += last * 0.85 * env;
  }
  final thumpStart = (_sr * 0.06).floor();
  for (int i = 0; i < (_sr * 0.35).floor() && thumpStart + i < n; i++) {
    final t = i / _sr;
    final env = math.exp(-i / (0.12 * _sr));
    out[thumpStart + i] += 0.4 * math.sin(2 * math.pi * 220 * t) * env;
  }
  return _normalize(out);
}

List<double> _buildAmbient() {
  final n = (_sr * 8).floor();
  final out = List<double>.filled(n, 0);
  const chords = [
    [220.00, 329.63, 440.00, 554.37],
    [196.00, 293.66, 392.00, 493.88],
    [174.61, 261.63, 349.23, 440.00],
  ];
  for (int c = 0; c < chords.length; c++) {
    final segN = n ~/ 3;
    final segStart = c * segN;
    for (final freq in chords[c]) {
      for (int i = 0; i < segN; i++) {
        final t = i / _sr;
        final localP = i / segN;
        final attack = math.min(1.0, localP / 0.2);
        final release = localP > 0.8 ? (1 - localP) / 0.2 : 1.0;
        final env = attack * release;
        final lfo = 1 + 0.08 * math.sin(2 * math.pi * 0.15 * t + c);
        out[segStart + i] +=
            0.06 * math.sin(2 * math.pi * freq * t) * env * lfo;
        out[segStart + i] +=
            0.02 * math.sin(2 * math.pi * freq * 2 * t) * env * lfo;
      }
      for (int i = 0; i < 22050 * 0.05; i++) {
        final fade = i / (22050 * 0.05);
        if (segStart + i >= n) break;
        out[segStart + i] *= fade;
      }
    }
  }
  return _normalizeBy(out, 1.2);
}

List<double> _normalize(List<double> x) {
  final peak = x.map((v) => v.abs()).reduce(math.max);
  if (peak < 0.0001) return x;
  final g = math.min(1.0, 0.85 / peak);
  return x.map((v) => v * g).toList();
}

List<double> _normalizeBy(List<double> x, double target) {
  final peak = x.map((v) => v.abs()).reduce(math.max);
  if (peak < 0.0001) return x;
  final g = target / peak;
  return x.map((v) => v * g).toList();
}

void _writeWav(Directory dir, String name, List<double> samples) {
  final bytes = <int>[];
  void w32(int v) {
    bytes.add(v & 0xff);
    bytes.add((v >> 8) & 0xff);
    bytes.add((v >> 16) & 0xff);
    bytes.add((v >> 24) & 0xff);
  }

  void w16(int v) {
    bytes.add(v & 0xff);
    bytes.add((v >> 8) & 0xff);
  }

  final dataSize = samples.length * 2;
  bytes.addAll('RIFF'.codeUnits);
  w32(36 + dataSize);
  bytes.addAll('WAVE'.codeUnits);
  bytes.addAll('fmt '.codeUnits);
  w32(16);
  w16(1); // PCM
  w16(1); // mono
  w32(_sr.round());
  w32(_sr.round() * 2);
  w16(2);
  w16(16);
  bytes.addAll('data'.codeUnits);
  w32(dataSize);
  for (final s in samples) {
    var v = (s.clamp(-1.0, 1.0) * 32767).round();
    if (v > 32767) v = 32767;
    if (v < -32768) v = -32768;
    w16(v);
  }
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(bytes);
  stdout.writeln('  wrote ${file.path} (${(samples.length / _sr).toStringAsFixed(1)}s)');
}
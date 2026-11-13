import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../content.dart';

/// Loads photo memories from a private Supabase Storage bucket.
/// Music stays bundled in the APK and is never read from Supabase.
class MediaCatalog extends ChangeNotifier {
  static const String projectUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  static const String bucketName = 'her-little-world-photos';
  static const int signedUrlLifetimeSeconds = 86400;
  static const Duration refreshThreshold = Duration(hours: 23);
  static const Duration signedUrlRefreshThreshold = refreshThreshold;

  final SupabaseClient? client;
  DateTime? _manifestLoadedAt;

  MediaCatalog({this.client}) {
    if (remoteEnabled && client?.auth.currentSession != null) {
      _restoreSession();
    } else {
      checkingSession = false;
    }
  }

  bool get remoteEnabled =>
      projectUrl.trim().isNotEmpty &&
      publishableKey.trim().isNotEmpty &&
      client != null;

  bool checkingSession = true;
  bool connected = false;
  bool bypassed = false;
  bool loading = false;
  String? errorMessage;

  List<MemoryItem> gardenMemories = AppContent.gardenMemories;
  List<MemoryItem> treehouseMemories = AppContent.treehouseMemories;

  Future<void> _restoreSession() async {
    await loadPhotoManifest();
  }

  Future<bool> connect(String email, String password) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Enter your email and password.';
      notifyListeners();
      return false;
    }

    loading = true;
    bypassed = false;
    errorMessage = null;
    notifyListeners();

    try {
      await client!.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      return await loadPhotoManifest();
    } catch (error) {
      loading = false;
      connected = false;
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshIfStale() async {
    if (!remoteEnabled || !connected || loading || _manifestLoadedAt == null) {
      return;
    }
    if (DateTime.now().difference(_manifestLoadedAt!) >=
        signedUrlRefreshThreshold) {
      await loadPhotoManifest(silent: true);
    }
  }

  Future<void> refreshIfExpired() => refreshIfStale();

  Future<bool> loadPhotoManifest({bool silent = false}) async {
    if (!remoteEnabled || client!.auth.currentSession == null) {
      checkingSession = false;
      loading = false;
      notifyListeners();
      return false;
    }

    if (!silent) {
      loading = true;
      checkingSession = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final bytes = await client!
          .storage
          .from(bucketName)
          .download('manifest.json');
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The photo manifest is not a JSON object.');
      }

      final results = await Future.wait([
        _mergeMemories(decoded['garden'], AppContent.gardenMemories),
        _mergeMemories(decoded['treehouse'], AppContent.treehouseMemories),
      ]);
      gardenMemories = results[0];
      treehouseMemories = results[1];

      // The playlist always comes from assets bundled in the APK.
      connected = true;
      loading = false;
      checkingSession = false;
      _manifestLoadedAt = DateTime.now();
      notifyListeners();
      return true;
    } catch (error) {
      loading = false;
      checkingSession = false;
      if (!silent) {
        connected = false;
        errorMessage = _friendlyError(error);
      }
      notifyListeners();
      return false;
    }
  }

  Future<List<MemoryItem>> _mergeMemories(
    dynamic rawItems,
    List<MemoryItem> fallback,
  ) async {
    if (rawItems is! List) return fallback;

    return Future.wait(
      List.generate(fallback.length, (index) async {
        final raw = index < rawItems.length ? rawItems[index] : null;
        if (raw is! Map) {
          return fallback[index];
        }

        final message = raw['message'] is String
            ? raw['message'] as String
            : fallback[index].message;
        final path = raw['path'] is String ? raw['path'] as String : null;

        String? signedUrl;
        if (path != null &&
            path.startsWith('photos/') &&
            !path.contains('..') &&
            !path.startsWith('/')) {
          signedUrl = await client!
              .storage
              .from(bucketName)
              .createSignedUrl(path, signedUrlLifetimeSeconds);
        }

        return MemoryItem(
          message: message,
          photoAsset: fallback[index].photoAsset,
          photoUrl: signedUrl,
        );
      }),
    );
  }

  String _friendlyError(Object error) {
    if (error is AuthException) return error.message;
    if (error is StorageException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  void continueWithoutCloud() {
    connected = false;
    bypassed = true;
    gardenMemories = AppContent.gardenMemories;
    treehouseMemories = AppContent.treehouseMemories;
    notifyListeners();
  }

  void reopenGate() {
    if (!remoteEnabled || connected) return;
    bypassed = false;
    errorMessage = null;
    notifyListeners();
  }
}

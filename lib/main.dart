import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state/journey_state.dart';
import 'services/audio_manager.dart';
import 'services/media_catalog.dart';
import 'theme/app_theme.dart';
import 'screens/gift_screen.dart';
import 'widgets/media_access_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfigured = MediaCatalog.projectUrl.isNotEmpty &&
      MediaCatalog.publishableKey.isNotEmpty;
  if (supabaseConfigured) {
    await Supabase.initialize(
      url: MediaCatalog.projectUrl,
      publishableKey: MediaCatalog.publishableKey,
    );
  }

  // Keep the app locked in portrait orientation.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(HerLittleWorldApp(supabaseConfigured: supabaseConfigured));
}

class HerLittleWorldApp extends StatefulWidget {
  final bool supabaseConfigured;

  const HerLittleWorldApp({super.key, this.supabaseConfigured = false});

  @override
  State<HerLittleWorldApp> createState() => _HerLittleWorldAppState();
}

class _HerLittleWorldAppState extends State<HerLittleWorldApp> {
  late final AppLifecycleListener _lifecycle;
  late final MediaCatalog _mediaCatalog;

  @override
  void initState() {
    super.initState();
    _mediaCatalog = MediaCatalog(
      client: widget.supabaseConfigured ? Supabase.instance.client : null,
    );
    _lifecycle = AppLifecycleListener(
      onPause: () {
        AudioManager.instance.pauseAmbient();
      },
      onResume: () {
        AudioManager.instance.resumeAmbient();
        _mediaCatalog.refreshIfExpired();
      },
      onExitRequested: () async {
        await AudioManager.instance.dispose();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _mediaCatalog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JourneyState()),
        ChangeNotifierProvider.value(value: _mediaCatalog),
      ],
      child: MaterialApp(
        title: 'Her Little World',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MediaAccessGate(child: GiftScreen()),
      ),
    );
  }
}

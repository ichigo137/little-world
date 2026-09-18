import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state/journey_state.dart';
import 'services/audio_manager.dart';
import 'theme/app_theme.dart';
import 'screens/gift_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the app locked in portrait orientation.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const HerLittleWorldApp());
}

class HerLittleWorldApp extends StatefulWidget {
  const HerLittleWorldApp({super.key});

  @override
  State<HerLittleWorldApp> createState() => _HerLittleWorldAppState();
}

class _HerLittleWorldAppState extends State<HerLittleWorldApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        await AudioManager.instance.dispose();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JourneyState(),
      child: MaterialApp(
        title: 'Her Little World',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const GiftScreen(),
      ),
    );
  }
}

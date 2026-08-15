import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state/journey_state.dart';
import 'theme/app_theme.dart';
import 'screens/gift_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the app locked in portrait orientation.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const HerLittleWorldApp());
}

class HerLittleWorldApp extends StatelessWidget {
  const HerLittleWorldApp({super.key});

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

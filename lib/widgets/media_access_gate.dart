import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/media_catalog.dart';
import '../theme/app_theme.dart';

/// Optional sign-in gate for the private Supabase photo collection.
class MediaAccessGate extends StatefulWidget {
  final Widget child;

  const MediaAccessGate({super.key, required this.child});

  @override
  State<MediaAccessGate> createState() => _MediaAccessGateState();
}

class _MediaAccessGateState extends State<MediaAccessGate> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect(MediaCatalog catalog) async {
    FocusScope.of(context).unfocus();
    await catalog.connect(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<MediaCatalog>();
    if (!catalog.remoteEnabled || catalog.connected || catalog.bypassed) {
      return widget.child;
    }

    if (catalog.checkingSession) {
      return const Scaffold(
        backgroundColor: AppTheme.nightDeep,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.blush),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.nightDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, size: 54, color: AppTheme.blush),
                  const SizedBox(height: 20),
                  Text(
                    'a little world, just for you',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.caveat(
                      fontSize: 32,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to unlock your private photo memories. Your playlist is already inside the app.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comfortaa(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textSoft,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: _decoration('Email address'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _connect(catalog),
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: _decoration('Password'),
                  ),
                  if (catalog.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      catalog.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.blush),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: catalog.loading ? null : () => _connect(catalog),
                      child: catalog.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Unlock our memories'),
                    ),
                  ),
                  TextButton(
                    onPressed: catalog.loading
                        ? null
                        : catalog.continueWithoutCloud,
                    child: const Text(
                      'Continue without cloud photos',
                      style: TextStyle(color: AppTheme.textSoft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSoft),
        filled: true,
        fillColor: AppTheme.nightSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );
}

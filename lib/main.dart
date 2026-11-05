import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/theme.dart';
import 'data/content_repository.dart';
import 'data/lumen_settings.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await LumenSettings.load();
  runApp(LumenApp(settings: settings, repository: ContentRepository()));
}

class LumenApp extends StatefulWidget {
  const LumenApp({super.key, required this.settings, required this.repository});

  final LumenSettings settings;
  final ContentRepository repository;

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// "Automático" follows the phone.
  @override
  void didChangePlatformBrightness() => setState(() {});

  LumenPalette _palette() => switch (widget.settings.themeMode) {
    'light' => LumenPalette.light,
    'system' =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.light
          ? LumenPalette.light
          : LumenPalette.dark,
    _ => LumenPalette.dark,
  };

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return LumenScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          // Colors are read from the current palette while building, so the
          // whole tree is rebuilt (keyed) when the theme changes.
          final palette = _palette();
          LumenPalette.current = palette;
          final light = palette.brightness == Brightness.light;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
            child: MaterialApp(
              key: ValueKey(palette.brightness),
              title: 'Lumen',
              debugShowCheckedModeBanner: false,
              theme: buildLumenTheme(),
              // The app has its own text size setting; cap the system one so
              // layouts stay composed (Biblia Traditio does the same).
              builder:
                  (context, child) => MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: child!,
                  ),
              home:
                  settings.onboardingDone
                      ? HomeShell(repository: widget.repository)
                      : OnboardingScreen(
                        onDone: () => settings.onboardingDone = true,
                      ),
            ),
          );
        },
      ),
    );
  }
}

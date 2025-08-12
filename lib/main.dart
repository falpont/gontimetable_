import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_app.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash and prevent Flutter from drawing the first frame
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  binding.deferFirstFrame();

  await initializeDateFormatting('ko_KR', null);

  runApp(const GonScheduleApp());
}

class GonScheduleApp extends StatelessWidget {
  const GonScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '곤스케줄',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF374151),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      home: const _InitialRoute(),
    );
  }
}


class _InitialRoute extends StatefulWidget {
  const _InitialRoute();

  @override
  State<_InitialRoute> createState() => _InitialRouteState();
}

class _InitialRouteState extends State<_InitialRoute> {
  late final Future<bool> _future;

  Future<bool> _hasGradeClass() async {
    final prefs = await SharedPreferences.getInstance();
    final g = prefs.getInt('grade');
    final c = prefs.getInt('class');
    // 디버그 로그
    debugPrint('[Main] prefs grade=$g, class=$c');
    return g != null && c != null;
  }

  @override
  void initState() {
    super.initState();
    _future = _hasGradeClass();

    _future.whenComplete(() {
      // Remove native splash and allow first frame only after the next frame,
      // so we transition straight from splash -> first Flutter frame.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        FlutterNativeSplash.remove();
        WidgetsBinding.instance.allowFirstFrame();

        // Apply system UI style after first frame to avoid flicker
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const MainApp();
        }
        return const OnboardingScreen();
      },
    );
  }
}

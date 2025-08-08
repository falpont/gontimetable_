import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gontimetable/select_page.dart';
import 'package:gontimetable/highschool_timetable.dart';
import 'package:gontimetable/PersonalTimetable.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const SpotlightIntroScreen();

  @override
  void initState() {
    super.initState();
    _checkSavedGradeClass();
  }

  Future<void> _checkSavedGradeClass() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic rawGrade = prefs.get('savedGrade');
    final dynamic rawClass = prefs.get('savedClass');
    final String? rawSections = prefs.getString('savedSelectedSections');

    final int? savedGrade = rawGrade is int
        ? rawGrade
        : (rawGrade is String ? int.tryParse(rawGrade) : null);
    final int? savedClass = rawClass is int
        ? rawClass
        : (rawClass is String ? int.tryParse(rawClass) : null);

    if (savedGrade != null
        && savedClass != null
        && rawSections != null
        && rawSections.trim().isNotEmpty
        && rawSections.trim() != '{}') {
      final Map<String, dynamic> jsonMap = json.decode(rawSections) as Map<String, dynamic>;
      final Map<String, String> selectedSections = jsonMap.map(
        (k, v) => MapEntry(k, v.toString()),
      );
      if (selectedSections.isNotEmpty) {
        setState(() {
          _defaultScreen = PersonalTimetable(
            grade: savedGrade,
            classNum: savedClass,
            selectedSections: selectedSections,
          );
        });
      }
    } else if (savedGrade != null && savedClass != null) {
      setState(() {
        _defaultScreen = HighSchoolTimetable(
          grade: savedGrade,
          classNum: savedClass,
        );
      });
    } else {
      setState(() {
        _defaultScreen = const GradeClassSelectionScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "곤시간표",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      home: Builder(
        builder: (context) {
          return Center(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: _defaultScreen,
            ),
          );
        },
      ),
    );
  }
}

class SpotlightIntroScreen extends StatelessWidget {
  const SpotlightIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFD54F), // yellow color
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Spotlight',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D8D8D), // gray color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
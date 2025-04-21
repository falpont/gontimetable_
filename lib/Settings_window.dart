import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gontimetable/PersonalTimetable.dart';
import 'package:gontimetable/highschool_timetable.dart';
import 'select_page.dart';
import 'dart:convert';

class SettingsWindow extends StatefulWidget {
  final int grade;
  final int classNum;
  final bool isPersonal;
  final Map<String, String>? selectedSections;

  const SettingsWindow({
    Key? key,
    required this.grade,
    required this.classNum,
    this.isPersonal = false,
    this.selectedSections,
  }) : super(key: key);

  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  int selectedGrade = 1;
  int selectedClass = 1;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGrade = prefs.getInt('savedGrade') ?? 1;
      selectedClass = prefs.getInt('savedClass') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('savedGrade', selectedGrade);
    await prefs.setInt('savedClass', selectedClass);
    final rawSections = prefs.getString('savedSelectedSections');
    if (rawSections != null) {
      final Map<String, dynamic> jsonMap = json.decode(rawSections) as Map<String, dynamic>;
      final Map<String, String> selectedSections = {
        for (var e in jsonMap.entries) e.key: e.value.toString()
      };
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalTimetable(
            grade: selectedGrade,
            classNum: selectedClass,
            selectedSections: selectedSections,
          ),
        ),
        (route) => false,
      );
    } else {
      // Remove any previously saved personal timetable selections
      await prefs.remove('savedSelectedSections');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HighSchoolTimetable(
            grade: selectedGrade,
            classNum: selectedClass,
          ),
        ),
        (route) => false
      );
    }
  }

  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedGrade');
    await prefs.remove('savedClass');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GradeClassSelectionScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / 375;
    return Scaffold(
      appBar: AppBar(
        title: Text("설정", style: TextStyle(fontSize: 20 * scale)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("학년 및 반 재설정", style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: ElevatedButton(
                onPressed: _resetSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
                ),
                child: Text("학년/반 선택 화면으로 이동", style: TextStyle(fontSize: 16 * scale, color: Colors.white)),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Text("문의 : falpont9927@gmail.com", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.015),
            Text("인스타그램 : sh_53sum_ DM", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.015),
            Text("20515성승현", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.015),
            Text("아직 미완성인 앱입니다.", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.015),
            Text("문제점, 오류 전부 보내주세요.", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
            SizedBox(height: screenHeight * 0.015),
            Text("모두 반영하겠습니다.", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
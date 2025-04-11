import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'highschool_timetable.dart';
import 'select_page.dart';

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key});
  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  String selectedGrade = "1";
  String selectedClass = "1";

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGrade = (prefs.getInt('savedGrade')?.toString()) ?? "1";
      selectedClass = (prefs.getInt('savedClass')?.toString()) ?? "1";
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedGrade', selectedGrade);
    await prefs.setString('savedClass', selectedClass);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HighSchoolTimetable(
          grade: selectedGrade,
          classNum: selectedClass,
        ),
      ),
          (Route<dynamic> route) => false,
    );
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
            Text("이 앱은 아직 미완성입니다.", style: TextStyle(fontSize: 16 * scale), textAlign: TextAlign.center),
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
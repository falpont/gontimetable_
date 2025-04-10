import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'highschool_timetable.dart';
import 'select_page.dart';

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({Key? key}) : super(key: key);

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
      selectedGrade = prefs.getString('savedGrade') ?? "1";
      selectedClass = prefs.getString('savedClass') ?? "1";
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
      MaterialPageRoute(
          builder: (context) => GradeClassSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "학년 및 반 재설정",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                "학년/반 선택 화면으로 이동",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
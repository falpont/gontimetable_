import 'package:flutter/material.dart';
import 'package:gontimetable/highschool_timetable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 이 줄이 올바르게 작성되어야 함.
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GradeClassSelectionScreen(),
    );
  }
}

class GradeClassSelectionScreen extends StatefulWidget {
  @override
  _GradeClassSelectionScreenState createState() => _GradeClassSelectionScreenState();
}

class _GradeClassSelectionScreenState extends State<GradeClassSelectionScreen> {
  int selectedGrade = 1;
  int selectedClass = 1;

  @override
  void initState() {
    super.initState();
    // FCM 토큰을 가져와서 콘솔에 출력
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '학년 반 고르기',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 100, height: 60),
            Text(
              '$selectedGrade학년 $selectedClass반',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // 학년, 반 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropdown("학년", selectedGrade, [1, 2, 3], (value) {
                  setState(() {
                    selectedGrade = value!;
                  });
                }),
                const SizedBox(width: 20),
                _buildDropdown("반", selectedClass, [1, 2, 3, 4, 5, 6], (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 100),
            // 계속하기 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HighSchoolTimetable(
                      grade: "$selectedGrade",
                      classNum: "$selectedClass",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                '계속하기',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, int selectedValue, List<int> options, ValueChanged<int?> onChanged) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 50,
          color: Colors.blue[800],
          child: Center(
            child: Text(
              '$selectedValue',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        Container(
          width: 80,
          height: 150,
          color: Colors.grey[300],
          child: SingleChildScrollView(
            child: Column(
              children: options.map((e) {
                return GestureDetector(
                  onTap: () => onChanged(e),
                  child: Container(
                    height: 50,
                    color: selectedValue == e ? Colors.grey[500] : Colors.grey[300],
                    child: Center(
                      child: Text(
                        '$e',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:gontimetable/highschool_timetable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class GradeClassSelectionScreen extends StatefulWidget {
  const GradeClassSelectionScreen({super.key});

  @override
  _GradeClassSelectionScreenState createState() => _GradeClassSelectionScreenState();
}

class _GradeClassSelectionScreenState extends State<GradeClassSelectionScreen> {
  int selectedGrade = 1;
  int selectedClass = 1;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      if (token != null) {
        saveToken(token);
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('news').then((_) {
      print("Subscribed to 'news' topic");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
    });
  }

  Future<void> saveToken(String token) async {
    print("토큰 저장 로직: 받은 토큰: $token");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth >= 700;
    final double scaleFactor = isTablet ? 1.0 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Text(
                  "곤시간표",
                  style: TextStyle(
                    fontSize: screenWidth * 0.09 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  '$selectedGrade학년 $selectedClass반',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDropdown("학년", selectedGrade, [1, 2, 3], (value) {
                      setState(() {
                        selectedGrade = value!;
                      });
                    }, screenWidth, scaleFactor),
                    SizedBox(width: screenWidth * 0.05),
                    _buildDropdown("반", selectedClass, [1, 2, 3, 4, 5, 6], (value) {
                      setState(() {
                        selectedClass = value!;
                      });
                    }, screenWidth, scaleFactor),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('savedGrade', selectedGrade);
                    await prefs.setInt('savedClass', selectedClass);
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
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.02,
                    ),
                  ),
                  child: Text(
                    '계속하기',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045 * scaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      int selectedValue,
      List<int> options,
      ValueChanged<int?> onChanged,
      double screenWidth,
      double scaleFactor,
      ) {
    double containerWidth = screenWidth * 0.2 * scaleFactor;

    return Column(
      children: [
        Container(
          width: containerWidth,
          height: containerWidth * 0.6,
          color: Colors.blue[800],
          child: Center(
            child: Text(
              '$selectedValue',
              style: TextStyle(
                fontSize: containerWidth * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          width: containerWidth,
          height: containerWidth * 2,
          color: Colors.grey[300],
          child: SingleChildScrollView(
            child: Column(
              children: options.map((e) {
                return GestureDetector(
                  onTap: () => onChanged(e),
                  child: Container(
                    height: containerWidth * 0.6,
                    color: selectedValue == e ? Colors.grey[500] : Colors.grey[300],
                    child: Center(
                      child: Text(
                        '$e',
                        style: TextStyle(fontSize: containerWidth * 0.3),
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
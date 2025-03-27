import 'package:flutter/material.dart';
import 'package:gontimetable/Settings_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'highschool_timetable.dart';
import 'school_schedule.dart';

class MealScreen extends StatefulWidget {
  final String grade;
  final String classNum;

  const MealScreen({Key? key, required this.grade, required this.classNum}) : super(key: key);

  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  bool isLoading = false;
  List<Map<String, String>> weeklyMeals = [];
  // 오늘 날짜 (정렬 & 카드 색상 표시용)
  String _todayRaw = "";

  @override
  void initState() {
    super.initState();
    fetchWeeklyMeal();
  }

  Future<void> fetchWeeklyMeal() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl = "http://xn--s39a8pla116tb6t.kro.kr/api/weekly_meal";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          // 오늘 날짜를 "YYYY-MM-DD" 형태로 보관
          DateTime now = DateTime.now();
          _todayRaw =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          List<Map<String, String>> meals = [];
          for (var item in jsonData) {
            // 예) "date": "20250317"
            String rawDate = item["date"] ?? "";
            String mealContent = item["meal"]?.toString() ?? "급식 정보 없음";

            // 날짜 변환: YYYYMMDD → "3월 17일 (금)" 형식
            String formattedDate = rawDate;
            String dateTimeString = ""; // 정렬, 오늘 급식 판별용

            if (rawDate.length == 8) {
              String yearStr = rawDate.substring(0, 4);
              String monthStr = rawDate.substring(4, 6);
              String dayStr = rawDate.substring(6, 8);

              int year = int.parse(yearStr);
              int month = int.parse(monthStr);
              int day = int.parse(dayStr);

              DateTime dt = DateTime(year, month, day);
              final weekdays = ["월", "화", "수", "목", "금", "토", "일"];
              String weekdayStr = weekdays[dt.weekday - 1];

              formattedDate = "${month}월 ${day}일 ($weekdayStr)";
              // 정렬용: "YYYY-MM-DD"
              dateTimeString = "$yearStr-$monthStr-$dayStr";
            }

            meals.add({
              "rawDate": rawDate,
              "dateTime": dateTimeString,
              "date": formattedDate,
              "meal": mealContent,
            });
          }

          // 오늘 급식이 가장 위로 오도록 정렬
          meals.sort((a, b) {
            String aDate = a["dateTime"] ?? "";
            String bDate = b["dateTime"] ?? "";

            if (aDate == _todayRaw && bDate == _todayRaw) return 0;
            if (aDate == _todayRaw) return -1;
            if (bDate == _todayRaw) return 1;
            return aDate.compareTo(bDate);
          });

          setState(() {
            weeklyMeals = meals;
          });
        }
      }
    } catch (e) {
      print("Error fetching weekly meal: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// AppBar (설정 버튼 + "오늘의 급식" 제목, Bold 처리)
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("곤고급식", style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                builder: (context) => SettingsWindow(),
                ),
            );
            // TODO: 설정 페이지 이동
          },
        ),
      ],
    );
  }

  /// 하단 네비게이션 바 (시간표, 급식, 학사일정)
  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          // 시간표 버튼: 알림시계 아이콘
          Expanded(
            child: InkWell(
              onTap: () {
                // 시간표 화면으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HighSchoolTimetable(
                      grade: widget.grade,
                      classNum: widget.classNum,
                    ),
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(
                    Icons.access_alarm,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // 급식 버튼: 현재 페이지
          Expanded(
            child: InkWell(
              onTap: () {
                // 현재 페이지
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.blueAccent,
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // 학사일정 버튼
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchoolSchedule(
                    grade: widget.grade,
                    classNum: widget.classNum,
                  )),
                );
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단에 설정 버튼 + "오늘의 급식" 제목
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: weeklyMeals.length,
        itemBuilder: (context, index) {
          final mealData = weeklyMeals[index];
          bool isToday = (mealData["dateTime"] == _todayRaw);

          return Card(
            // 오늘 급식이면 하늘색 배경
            color: isToday ? Colors.lightBlue[50] : null,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 + 오늘의 급식
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealData["date"] ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (isToday)
                        Text(
                          "오늘의 급식",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 급식 내용
                  Text(
                    mealData["meal"] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gontimetable/Settings_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'highschool_timetable.dart';
import 'school_schedule.dart';
import 'PersonalTimetable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealScreen extends StatefulWidget {
  final int grade;
  final int classNum;
  final bool isPersonal;
  final Map<String, String>? selectedSections;

  const MealScreen({
    Key? key,
    required this.grade,
    required this.classNum,
    required this.isPersonal,
    this.selectedSections,
  }) : super(key: key);

  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  bool isLoading = false;
  List<Map<String, String>> weeklyMeals = [];
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
          DateTime now = DateTime.now();
          _todayRaw = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          List<Map<String, String>> meals = [];
          for (var item in jsonData) {
            String rawDate = item["date"] ?? "";
            String mealContent = item["meal"]?.toString() ?? "급식 정보 없음";

            String formattedDate = rawDate;
            String dateTimeString = "";

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
              dateTimeString = "$yearStr-$monthStr-$dayStr";
            }

            meals.add({
              "rawDate": rawDate,
              "dateTime": dateTimeString,
              "date": formattedDate,
              "meal": mealContent,
            });
          }

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

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("곤고급식", style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsWindow(
                  grade: widget.grade,
                  classNum: widget.classNum,
                  isPersonal: widget.isPersonal,
                  selectedSections: widget.selectedSections,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    final screenHeight = MediaQuery.of(context).size.height;
    double navBarHeight = screenHeight * 0.08;
    if (navBarHeight < 60) navBarHeight = 60;

    return Container(
      height: navBarHeight,
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (widget.isPersonal) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalTimetable(
                        grade: widget.grade,
                        classNum: widget.classNum,
                        selectedSections: widget.selectedSections ?? {},
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HighSchoolTimetable(
                        grade: widget.grade,
                        classNum: widget.classNum,
                      ),
                    ),
                  );
                }
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(
                    Icons.access_alarm,
                    color: Colors.white,
                    size: navBarHeight * 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                  //페이지 추가할거면 여기다가 하면 된다.
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.blueAccent,
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: navBarHeight * 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchoolSchedule(
                      grade: widget.grade,
                      classNum: widget.classNum,
                      isPersonal: widget.isPersonal,
                      selectedSections: widget.selectedSections,
                    ),
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: navBarHeight * 0.5,
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
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: weeklyMeals.length,
        itemBuilder: (context, index) {
          final mealData = weeklyMeals[index];
          bool isToday = (mealData["dateTime"] == _todayRaw);

          return Card(
            color: isToday ? Colors.lightBlue[50] : null,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
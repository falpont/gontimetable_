import 'package:flutter/material.dart';
import 'package:gontimetable/school_schedule.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meal_screen.dart';
import 'Settings_window.dart';

class HighSchoolTimetable extends StatefulWidget {
  final String grade;
  final String classNum;

  const HighSchoolTimetable({
    Key? key,
    required this.grade,
    required this.classNum,
  }) : super(key: key);

  @override
  _HighSchoolTimetableState createState() => _HighSchoolTimetableState();
}

class _HighSchoolTimetableState extends State<HighSchoolTimetable> {
  late String selectedGrade;
  late String selectedClass;

  String currentDate = "불러오는 중...";
  bool isLoading = false;

  List<List<String>> timetableData = List.generate(
    5,
        (_) => List.generate(7, (_) => ""),
  );

  final List<String> periodLabels = [
    "1(9:10)",
    "2(10:10)",
    "3(11:10)",
    "4(12:10)",
    "5(13:10)",
    "6(14:50)",
    "7(15:50)",
  ];

  final List<String> dayLabels = [
    "월(17)",
    "화(18)",
    "수(19)",
    "목(20)",
    "금(21)",
  ];

  final Map<int, List<int>> periodStartTimeMap = {
    1: [9, 10],
    2: [10, 10],
    3: [11, 10],
    4: [12, 10],
    5: [13, 10],
    6: [14, 50],
    7: [15, 50],
  };

  final double cellHeight = 65.0;

  @override
  void initState() {
    super.initState();
    selectedGrade = widget.grade;
    selectedClass = widget.classNum;
    fetchCurrentDate();
    fetchTimetable();
  }

  Future<void> fetchCurrentDate() async {
    try {
      final response = await http.get(
        Uri.parse("http://xn--s39a8pla116tb6t.kro.kr/api/current_date"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey("current_date")) {
          String rawDate = data["current_date"];
          if (rawDate.contains("-")) {
            final splitted = rawDate.split("-");
            if (splitted.length == 3) {
              setState(() {
                currentDate = "${splitted[1]}월 ${splitted[2]}일";
              });
            } else {
              setState(() {
                currentDate = rawDate;
              });
            }
          } else {
            setState(() {
              currentDate = rawDate;
            });
          }
        } else {
          setState(() {
            currentDate = "날짜 정보 없음";
          });
        }
      } else {
        setState(() {
          currentDate = "날짜 정보 없음";
        });
      }
    } catch (e) {
      setState(() {
        currentDate = "날짜 오류";
      });
    }
  }

  Future<void> fetchTimetable() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl =
        "http://xn--s39a8pla116tb6t.kro.kr/api/weekly_timetable?grade=$selectedGrade&class=$selectedClass";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        timetableData = List.generate(
          5,
              (_) => List.generate(7, (_) => ""),
        );

        if (jsonData is List) {
          for (var item in jsonData) {
            final periodStr = item["period"]?.toString() ?? "";
            int? pIndex = int.tryParse(periodStr);
            if (pIndex != null && pIndex >= 1 && pIndex <= 7) {
              final subjects = item["subjects"];
              int periodIndex = pIndex - 1;
              if (subjects is List) {
                for (int dayIndex = 0; dayIndex < 5; dayIndex++) {
                  if (dayIndex < subjects.length) {
                    timetableData[dayIndex][periodIndex] =
                        subjects[dayIndex]?.toString() ?? "";
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching timetable: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int getTodayIndex() {
    final w = DateTime.now().weekday;
    if (w >= 1 && w <= 5) {
      return w - 1;
    } else {
      return -1;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        "곤시간표",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsWindow()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            currentDate,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedGrade,
                items: ["1", "2", "3"]
                    .map((g) => DropdownMenuItem(value: g, child: Text("$g학년")))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedGrade = value;
                    });
                  }
                },
              ),
              SizedBox(width: 20),
              DropdownButton<String>(
                value: selectedClass,
                items: ["1", "2", "3", "4", "5", "6"]
                    .map((c) => DropdownMenuItem(value: c, child: Text("$c반")))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedClass = value;
                    });
                  }
                },
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: fetchTimetable,
                child: Text("확인"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
          outside: BorderSide(color: Colors.grey.shade400),
        ),
        columnWidths: {
          0: FixedColumnWidth(68),
          1: FixedColumnWidth(55),
          2: FixedColumnWidth(55),
          3: FixedColumnWidth(55),
          4: FixedColumnWidth(55),
          5: FixedColumnWidth(55),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              Container(
                height: cellHeight,
                alignment: Alignment.center,
                child: Text("교시", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (int i = 0; i < dayLabels.length; i++)
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  child: Text(dayLabels[i], style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          for (int pIndex = 0; pIndex < 7; pIndex++)
            TableRow(
              children: [
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  child: Text(periodLabels[pIndex]),
                ),
                for (int dIndex = 0; dIndex < 5; dIndex++)
                  Container(
                    height: cellHeight,
                    alignment: Alignment.center,
                    child: Text(
                      timetableData[dIndex][pIndex].isEmpty
                          ? "-"
                          : timetableData[dIndex][pIndex],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(Icons.access_alarm, color: Colors.white, size: 28),
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
                    builder: (context) => MealScreen(
                      grade: selectedGrade,
                      classNum: selectedClass,
                    ),
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.blueAccent,
                child: Center(
                  child: Icon(Icons.fastfood, color: Colors.white, size: 28),
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
                      grade: selectedGrade,
                      classNum: selectedClass,
                    ),
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Icon(Icons.calendar_today, color: Colors.white, size: 28),
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
      body: Column(
        children: [
          _buildTopArea(),
          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildTimetableTable()),
                ],
              ),
            ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }
}
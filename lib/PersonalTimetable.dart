import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gontimetable/school_schedule.dart';
import 'meal_screen.dart';
import 'Settings_window.dart';

class PersonalTimetable extends StatefulWidget {
  final int grade;
  final int classNum;
  final Map<String, String> selectedSections;
  final bool isPersonal;

  const PersonalTimetable({
    Key? key,
    required this.grade,
    required this.classNum,
    required this.selectedSections,
    this.isPersonal = true,
  }) : super(key: key);

  @override
  State<PersonalTimetable> createState() => _PersonalTimetableState();
}

class _PersonalTimetableState extends State<PersonalTimetable> {
  bool isLoading = false;
  String currentDate = "불러오는 중...";
  late int selectedGrade = widget.grade;
  late int selectedClass = widget.classNum;
  List<List<String>> timetableData = List.generate(5, (_) => List.generate(7, (_) => ""));

  final List<String> periodLabels = [
    "1(9:10)","2(10:10)","3(11:10)","4(12:10)","5(13:10)","6(14:50)","7(15:50)"
  ];
  final List<String> dayLabels = ["월","화","수","목","금"];

  @override
  void initState() {
    super.initState();
    fetchCurrentDate();
    fetchSelectedSchedule();
  }

  Future<void> fetchSelectedSchedule() async {
    setState(() {
      isLoading = true;
    });

    // 1) 기본 반 시간표 불러오기
    final defaultUrl = Uri.parse(
      'http://xn--s39a8pla116tb6t.kro.kr/api/weekly_timetable'
          '?grade=${widget.grade}&class=${widget.classNum}',
    );
    try {
      final defaultRes = await http.get(defaultUrl);
      if (defaultRes.statusCode == 200) {
        final data = json.decode(defaultRes.body);
        if (data is List) {
          timetableData = List.generate(5, (_) => List.generate(7, (_) => ""));
          for (var item in data) {
            final periodStr = item["period"]?.toString() ?? '';
            final pIndex = int.tryParse(periodStr);
            if (pIndex != null && pIndex >= 1 && pIndex <= 7) {
              final subjects = item["subjects"];
              final periodIndex = pIndex - 1;
              if (subjects is List) {
                for (int d = 0; d < subjects.length && d < 5; d++) {
                  timetableData[d][periodIndex] = subjects[d]?.toString() ?? '';
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // 에러 처리
    }

    // 2) 선택과목 오버레이
    final splitUrl = Uri.parse(
      'http://xn--s39a8pla116tb6t.kro.kr/api/split_subjects/grade${widget.grade}',
    );
    try {
      final splitRes = await http.get(splitUrl);
      if (splitRes.statusCode == 200) {
        final List splitData = json.decode(splitRes.body);
        for (var item in splitData) {
          final key = item['key'];
          final name = key['field0'] as String;
          final period = key['field2'] as int;
          final weekday = key['field1'] as int;
          final value = item['value'] as String;
          final sel = widget.selectedSections[name] ?? '';
          if (sel == value) {
            final displayName = (key['field5'] as String?) ?? value;
            timetableData[weekday][period - 1] = displayName;
          }
        }
      }
    } catch (e) {
      // 에러 처리
    }

    setState(() {
      isLoading = false;
    });
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        "곤시간표",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      ),
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

  Widget _buildTopArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "개인시간표",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            currentDate,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 700;
    final double scale = isTablet ? 1.6  : 0.9; // iPad에서는 2배, iPhone에서는 1배

    final double baseFirstColumnWidth = 80.0;
    final double baseOtherColumnWidth = 68.0;
    final double baseCellHeight = 65.0;

    final double firstColWidth = baseFirstColumnWidth * scale;
    final double otherColWidth = baseOtherColumnWidth * scale;
    final double cellHeight = baseCellHeight * scale;

    // 기본 글자 크기를 scale에 따라 조정 (헤더와 셀을 별도로 지정)
    final double headerFontSize = 16.0 * scale;
    final double cellFontSize = 14.0 * scale;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
          outside: BorderSide(color: Colors.grey.shade400),
        ),
        columnWidths: {
          0: FixedColumnWidth(firstColWidth),
          for (int i = 1; i <= 5; i++) i: FixedColumnWidth(otherColWidth),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              Container(
                height: cellHeight,
                alignment: Alignment.center,
                child: Text(
                  "교시",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: headerFontSize,
                  ),
                ),
              ),
              for (int i = 0; i < dayLabels.length; i++)
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  child: Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: headerFontSize,
                    ),
                  ),
                ),
            ],
          ),
          for (int pIndex = 0; pIndex < 7; pIndex++)
            TableRow(
              children: [
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  child: Text(
                    periodLabels[pIndex],
                    style: TextStyle(fontSize: cellFontSize),
                  ),
                ),
                for (int dIndex = 0; dIndex < 5; dIndex++)
                  Container(
                    height: cellHeight,
                    alignment: Alignment.center,
                    child: Text(
                      timetableData[dIndex][pIndex].isEmpty
                          ? "-"
                          : timetableData[dIndex][pIndex],
                      style: TextStyle(fontSize: cellFontSize),
                    ),
                  ),
              ],
            ),
        ],
      ),
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
                //추가할거면 여기다가 해 병신아.
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealScreen(
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
      body: Column(
        children: [
          _buildTopArea(),
          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildTimetableTable()),
          _buildBottomNavBar(),
        ],
      ),
    );
  }
}

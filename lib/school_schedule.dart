import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meal_screen.dart';
import 'highschool_timetable.dart';
import 'Settings_window.dart';

class SchoolSchedule extends StatefulWidget {
  final String grade;
  final String classNum;

  const SchoolSchedule({Key? key, required this.grade, required this.classNum}) : super(key: key);

  @override
  _SchoolScheduleState createState() => _SchoolScheduleState();
}

class _SchoolScheduleState extends State<SchoolSchedule> {
  int selectedMonth = DateTime.now().month; // 기본값: 현재 월
  Map<int, String> eventsMap = {}; // key: day, value: event (현재 월에 해당하는 이벤트)
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAcademicSchedule(selectedMonth);
  }

  /// 달별 일수 계산
  int _daysInMonth(int year, int month) {
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      } else {
        return 28;
      }
    }
    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }

  /// 학사 일정 API 호출
  Future<void> fetchAcademicSchedule(int month) async {
    setState(() {
      isLoading = true;
      eventsMap.clear();
    });

    final apiUrl = "http://xn--s39a8pla116tb6t.kro.kr/api/academic_schedule";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          for (var item in jsonData) {
            final rawDate = item["date"] ?? ""; // 예: "20250301"
            final eventName = item["event"] ?? "";
            if (rawDate.length == 8) {
              final m = int.parse(rawDate.substring(4, 6));
              final d = int.parse(rawDate.substring(6, 8));
              if (m == month) {
                eventsMap[d] = eventName;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching academic schedule: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 월 선택 Dropdown (오른쪽 정렬)
  Widget _buildMonthDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(12, (index) => index + 1)
              .map((m) => DropdownMenuItem(
            value: m,
            child: Text(
              "$m월",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
              fetchAcademicSchedule(selectedMonth);
            }
          },
        ),
      ],
    );
  }

  /// 캘린더 UI (월~금만 표시)
  Widget _buildCalendar() {
    final now = DateTime.now();
    final year = now.year;
    final currentMonthDays = _daysInMonth(year, selectedMonth);

    // 평일 데이터 계산
    final List<Map<String, dynamic>> calendarCells = [];

    // 1. 첫 날이 월요일이 아니면 전월 평일 채우기
    final firstDay = DateTime(year, selectedMonth, 1);
    final offset = firstDay.weekday - 1;
    if (offset > 0) {
      int prevMonth, prevYear;
      if (selectedMonth == 1) {
        prevMonth = 12;
        prevYear = year - 1;
      } else {
        prevMonth = selectedMonth - 1;
        prevYear = year;
      }
      final daysInPrevMonth = _daysInMonth(prevYear, prevMonth);

      final List<int> prevWeekdays = [];
      int d = daysInPrevMonth;
      while (prevWeekdays.length < offset && d > 0) {
        final dt = DateTime(prevYear, prevMonth, d);
        if (dt.weekday >= 1 && dt.weekday <= 5) {
          prevWeekdays.insert(0, d);
        }
        d--;
      }
      for (int day in prevWeekdays) {
        calendarCells.add({"day": day, "isCurrent": false});
      }
    }

    // 2. 현재 달의 평일만 추가
    for (int d = 1; d <= currentMonthDays; d++) {
      final dt = DateTime(year, selectedMonth, d);
      if (dt.weekday >= 1 && dt.weekday <= 5) {
        calendarCells.add({
          "day": d,
          "isCurrent": true,
          "isToday": (year == now.year && selectedMonth == now.month && d == now.day),
        });
      }
    }

    // 3. 마지막 행 맞추기
    while (calendarCells.length % 5 != 0) {
      final nextDay = (calendarCells.length % 5) + 1;
      calendarCells.add({"day": nextDay, "isCurrent": false});
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        children: [
          // 헤더 (월, 화, 수, 목, 금)
          Row(
            children: ["월", "화", "수", "목", "금"]
                .map(
                  (day) => Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 5),
          // 평일 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.8,
            ),
            itemCount: calendarCells.length,
            itemBuilder: (context, index) {
              final cell = calendarCells[index];
              final dayNum = cell["day"] as int;
              final isCurrent = cell["isCurrent"] as bool;
              final isToday = cell["isToday"] ?? false;
              bool hasEvent = false;
              String eventName = "";
              if (isCurrent) {
                // 이벤트 매핑
                hasEvent = eventsMap.containsKey(dayNum);
                if (hasEvent) {
                  eventName = eventsMap[dayNum]!;
                }
              }
              return InkWell(
                onTap: isCurrent
                    ? () {
                  _showDaySchedule(dayNum, eventName);
                }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: isCurrent
                        ? (isToday
                        ? Colors.yellow.shade200
                        : (hasEvent ? Colors.red.shade50 : Colors.white))
                        : Colors.grey.shade200,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$dayNum",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          padding: const EdgeInsets.all(2),
                          color: Colors.red.shade100,
                          child: Text(
                            eventName,
                            style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDaySchedule(int dayNum, String eventName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$selectedMonth월 $dayNum일 일정", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            eventName.isNotEmpty ? eventName : "해당 날짜의 일정이 없습니다.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    final screenHeight = MediaQuery.of(context).size.height;
    double navBarHeight = screenHeight * 0.08;
    if (navBarHeight < 60) navBarHeight = 60;

    return SafeArea(
      child: Container(
        height: navBarHeight,
        color: Colors.blueGrey[50],
        child: Row(
          children: [
            // 시간표 버튼
            Expanded(
              child: InkWell(
                onTap: () {
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
                  child: const Center(
                    child: Icon(Icons.access_alarm, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            // 급식 버튼
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealScreen(
                        grade: widget.grade,
                        classNum: widget.classNum,
                      ),
                    ),
                  );
                },
                splashColor: Colors.white.withOpacity(0.3),
                child: Container(
                  color: Colors.blueAccent,
                  child: const Center(
                    child: Icon(Icons.fastfood, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            // 학사일정 버튼
            Expanded(
              child: InkWell(
                onTap: () {
                  // 현재 페이지이므로 동작 없음
                },
                splashColor: Colors.white.withOpacity(0.3),
                child: Container(
                  color: Colors.lightBlue,
                  child: const Center(
                    child: Icon(Icons.calendar_today, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 흰색
        elevation: 1, // 약간의 그림자
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "학사 일정",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsWindow()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildMonthDropdown(),
          const SizedBox(height: 8),
          isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
            child: SingleChildScrollView(
              child: _buildCalendar(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
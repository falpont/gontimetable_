import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meal_screen.dart';
import 'highschool_timetable.dart';

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
            String rawDate = item["date"] ?? ""; // 예: "20250301"
            String eventName = item["event"] ?? "";
            if (rawDate.length == 8) {
              int m = int.parse(rawDate.substring(4, 6));
              int d = int.parse(rawDate.substring(6, 8));
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
            child: Text("$m월", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  /// 캘린더 디자인 (평일만: 월, 화, 수, 목, 금)
  Widget _buildCalendar() {
    final now = DateTime.now();
    int year = now.year;
    int currentMonthDays = _daysInMonth(year, selectedMonth);

    // 리스트에 평일 셀 데이터를 채움
    List<Map<String, dynamic>> calendarCells = [];

    // 1. 현재 달의 첫 날의 요일이 월요일이 아니라면, 전월의 평일(필요한 만큼)을 채움
    DateTime firstDay = DateTime(year, selectedMonth, 1);
    int offset = firstDay.weekday - 1; // Monday=1 -> offset 0, Tuesday=2 -> offset 1, etc.
    if (offset > 0) {
      int prevMonth, prevYear;
      if (selectedMonth == 1) {
        prevMonth = 12;
        prevYear = year - 1;
      } else {
        prevMonth = selectedMonth - 1;
        prevYear = year;
      }
      int daysInPrevMonth = _daysInMonth(prevYear, prevMonth);
      // 전월의 마지막 평일부터 필요한 개수만큼 (역순으로 검색)
      List<int> prevWeekdays = [];
      int d = daysInPrevMonth;
      while (prevWeekdays.length < offset && d > 0) {
        DateTime dt = DateTime(prevYear, prevMonth, d);
        if (dt.weekday >= 1 && dt.weekday <= 5) {
          prevWeekdays.insert(0, d); // 앞에 삽입
        }
        d--;
      }
      for (int day in prevWeekdays) {
        calendarCells.add({
          "day": day,
          "isCurrent": false,
        });
      }
    }

    // 2. 현재 달의 평일만 추가 (월~금)
    for (int d = 1; d <= currentMonthDays; d++) {
      DateTime dt = DateTime(year, selectedMonth, d);
      if (dt.weekday >= 1 && dt.weekday <= 5) {
        calendarCells.add({
          "day": d,
          "isCurrent": true,
          "isToday": (year == now.year && selectedMonth == now.month && d == now.day),
        });
      }
    }

    // 3. 마지막 행이 5칸이 되도록 다음 달의 평일을 추가 (필요한 경우)
    while (calendarCells.length % 5 != 0) {
      int nextDay = (calendarCells.length % 5) + 1;
      calendarCells.add({
        "day": nextDay,
        "isCurrent": false,
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Column(
        children: [
          // 헤더 행 (평일: 월, 화, 수, 목, 금)
          Row(
            children: ["월", "화", "수", "목", "금"]
                .map((day) => Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 5),
          // 달력 그리드 (5열)
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
              var cell = calendarCells[index];
              int dayNum = cell["day"];
              bool isCurrent = cell["isCurrent"];
              bool isToday = cell["isToday"] ?? false;
              bool hasEvent = false;
              String eventName = "";
              if (isCurrent) {
                // 현재 달이면 eventsMap에서 확인
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
                        style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.black : Colors.grey),
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

  /// 캘린더 셀을 탭하면 해당 날의 일정 상세보기 Dialog를 보여주는 함수
  void _showDaySchedule(int dayNum, String eventName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$selectedMonth월 $dayNum일 일정", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            eventName.isNotEmpty ? eventName : "해당 날짜의 일정이 없습니다.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("닫기"),
            )
          ],
        );
      },
    );
  }

  /// 하단 네비게이션 바 (시간표, 급식, 학사일정)
  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          // 시간표 버튼: HighSchoolTimetable로 이동
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
                child: Center(
                  child: Icon(Icons.access_alarm, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          // 급식 버튼: MealScreen으로 이동
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
                child: Center(
                  child: Icon(Icons.fastfood, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          // 학사일정 버튼: 현재 페이지 (눌린 효과만)
          Expanded(
            child: InkWell(
              onTap: () {
                // 눌린 효과만 나타남.
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
      appBar: AppBar(
        title: const Text("학사 일정"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildMonthDropdown(),
          const SizedBox(height: 8),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(child: SingleChildScrollView(child: _buildCalendar())),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gontimetable/school_schedule.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meal_screen.dart';
import 'package:intl/intl.dart';

class HighSchoolTimetable extends StatefulWidget {
  final String grade;    // 초기 학년
  final String classNum; // 초기 반

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

  // API가 "2025-03-25" 형태로 준다고 가정 → "03월 25일" 형식으로 표시
  String currentDate = "불러오는 중...";
  bool isLoading = false;

  // 시간표 데이터 (월~금 5일, 1~7교시)
  // timetableData[dayIndex][periodIndex]
  // dayIndex: 0=월, 1=화, 2=수, 3=목, 4=금
  // periodIndex: 0~6 (1~7교시)
  List<List<String>> timetableData = List.generate(
    5,
        (_) => List.generate(7, (_) => ""),
  );

  // 왼쪽 첫 열(교시) 라벨: 예시로 7교시 (UI 표시에만 사용)
  final List<String> periodLabels = [
    "1(9:10)",
    "2(10:10)",
    "3(11:10)",
    "4(12:10)",
    "5(13:10)",
    "6(14:50)",
    "7(15:50)",
  ];

  // 상단 열(요일) 라벨: 예시로 월(17), 화(18), 수(19), 목(20), 금(21)
  final List<String> dayLabels = [
    "월(17)",
    "화(18)",
    "수(19)",
    "목(20)",
    "금(21)",
  ];

  // 교시별 실제 시작 시각 매핑 (알림 예약용)
  final Map<int, List<int>> periodStartTimeMap = {
    1: [9, 10],   // 1교시 → 09:10
    2: [10, 10],  // 2교시 → 10:10
    3: [11, 10],  // 3교시 → 11:10
    4: [12, 10],  // 4교시 → 12:10
    5: [13, 10],  // 5교시 → 13:10
    6: [14, 50],  // 6교시 → 14:50
    7: [15, 50],  // 7교시 → 15:50
  };

  // 행(셀) 높이 고정값 (사용자가 조절하지 않음)
  final double cellHeight = 65.0;

  @override
  void initState() {
    super.initState();
    selectedGrade = widget.grade;
    selectedClass = widget.classNum;
    fetchCurrentDate();
    fetchTimetable();
  }

  /// 오늘 날짜 API 호출 ("2025-03-25" 형태 → "03월 25일")
  Future<void> fetchCurrentDate() async {
    try {
      final response = await http.get(
        Uri.parse("http://xn--s39a8pla116tb6t.kro.kr/api/current_date"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey("current_date")) {
          String rawDate = data["current_date"]; // 예: "2025-03-25"
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

  /// 시간표 API 호출
  /// 예시 JSON: { "period": "1", "subjects": ["실용 국어", "진로활동", ...] }
  /// → subjects[0]=월, [1]=화, [2]=수, [3]=목, [4]=금
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

        // 초기화
        timetableData = List.generate(
          5,
              (_) => List.generate(7, (_) => ""),
        );

        // 예) [ { "period":"1", "subjects":["실용 국어", "진로활동", ...] }, ... ]
        if (jsonData is List) {
          for (var item in jsonData) {
            final periodStr = item["period"]?.toString() ?? "";
            int? pIndex = int.tryParse(periodStr);
            if (pIndex != null && pIndex >= 1 && pIndex <= 7) {
              final subjects = item["subjects"];
              int periodIndex = pIndex - 1; // 1교시 → index 0
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

  /// 오늘 요일 인덱스 (월:0, 화:1, 수:2, 목:3, 금:4; 주말이면 -1)
  int getTodayIndex() {
    final w = DateTime.now().weekday; // 1(월) ~ 7(일)
    if (w >= 1 && w <= 5) {
      return w - 1;
    } else {
      return -1;
    }
  }

  /// AppBar - 뒤로가기 버튼 제거, 설정 아이콘
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        "곤시간표",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      actions: [],
    );
  }

  /// 상단 영역 - 날짜, 학년·반 선택 (셀 크기 슬라이더 제거)
  Widget _buildTopArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 오늘 날짜 표시
          Text(
            currentDate,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // 학년, 반 선택
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

  /// 시간표 표 (월~금 5열, 1~7교시 7행)
  /// timetableData[dayIndex][pIndex]로 과목명 표시
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
          // 헤더 행 (교시, 월(17), 화(18), 수(19), 목(20), 금(21))
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
          // 실제 교시별 행 (7행)
          for (int pIndex = 0; pIndex < 7; pIndex++)
            TableRow(
              children: [
                // 교시 라벨
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  child: Text(periodLabels[pIndex]),
                ),
                // 월~금 5칸
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

  /// 하단 네비게이션 바 (시간표, 급식, 학사일정)
  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          // 시간표 버튼 (눌린 효과만)
          Expanded(
            child: InkWell(
              onTap: () {
                // 아무 기능 없음
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
          // 학사일정 버튼: SchoolSchedule으로 이동
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
      appBar: _buildAppBar(), // 뒤로가기 버튼 제거, 설정 아이콘 포함
      body: Column(
        children: [
          _buildTopArea(), // 학년·반 선택, 오늘 날짜 표시
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
          _buildBottomNavBar(), // 하단 네비게이션 바
        ],
      ),
    );
  }
}
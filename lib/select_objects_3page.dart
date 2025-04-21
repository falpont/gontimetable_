import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gontimetable/SectionDetailPage.dart';
import 'package:gontimetable/PersonalTimetable.dart';

class SelectObjects3Page extends StatefulWidget {
  final int grade;
  final int classNum;

  const SelectObjects3Page({
    Key? key,
    required this.grade,
    required this.classNum,
  }) : super(key: key);

  @override
  State<SelectObjects3Page> createState() => _SelectObjects3PageState();
}

class _SelectObjects3PageState extends State<SelectObjects3Page> {
  Map<int, String> selectedSubjects = {};
  bool showErrorG0 = false;
  bool showErrorG1 = false;
  bool showErrorG2 = false;
  bool showErrorG3 = false;
  bool showErrorG4 = false;
  bool showErrorG5 = false;

  final List<List<String>> subjectGroups = [
    // Section 0: 택3
    ['화법과작문','언어와매체','확률과통계','미적분','영어독해와작문','영어회화'],
    // Section 1: 택2
    ['고전읽기','심화국어','경제수학','기하','진로영어','영어권문화'],
    // Section 2: 택3
    ['세계지리','경제','여행지리','사회문제탐구','윤리와사상','생활과윤리','정치와법','물리학ⅠⅠ','화학ⅠⅠ','생명과학ⅠⅠ','생활과학'],
    // Section 3: 택1
    ['미술창작','음악감상과비평'],
    // Section 4: 택1
    ['기업과경영','체육전공실기기초','프로그래밍'],
    // Section 5: 택1
    ['철학','교육학','창작활동'],
  ];

  List<dynamic> splitSubjects = [];
  bool isLoading = true;

  Future<void> fetchSplitSubjects() async {
    final url = Uri.parse(
      'http://xn--s39a8pla116tb6t.kro.kr/api/split_subjects/grade${widget.grade}'
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        splitSubjects = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSplitSubjects();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("3학년 선택과목 선택"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(subjectGroups.length, (i) {
              final titles = [
                '기초교과 3개 선택',
                '기초교과 2개 선택',
                '탐구과목 3개 선택',
                '예술교과 1개 선택',
                '교과 영역 간 선택과목 1개 선택',
                '기술가정/교양교과 1개 선택',

              ];
              final errors = [showErrorG0, showErrorG1, showErrorG2, showErrorG3, showErrorG4, showErrorG5];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i > 0) SizedBox(height: 24),
                  Row(
                    children: [
                      Text(titles[i], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (errors[i])
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('선택하세요', style: TextStyle(color: Colors.red, fontSize: 16)),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subjectGroups[i].map((subject) {
                      final sel = selectedSubjects[i];
                      List<String> existing = sel?.split(',') ?? [];
                      final needed = [3,2,3,1,1,1][i];
                      final isSelected = needed == 1
                        ? sel == subject
                        : existing.contains(subject);
                      return ChoiceChip(
                        label: Text(subject),
                        selected: isSelected,
                        selectedColor: Colors.black,
                        onSelected: (_) {
                          setState(() {
                            if (needed == 1) {
                              selectedSubjects[i] = subject;
                              _setErrorFlag(i, false);
                            } else {
                              if (isSelected) {
                                existing.remove(subject);
                              } else if (existing.length < needed) {
                                existing.add(subject);
                              }
                              if (existing.isEmpty) {
                                selectedSubjects.remove(i);
                              } else {
                                selectedSubjects[i] = existing.join(',');
                              }
                              _setErrorFlag(i, false);
                            }
                          });
                        },
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _onNextPressed,
          child: const Text(
            "저장하고 계속하기",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _setErrorFlag(int idx, bool value) {
    switch(idx) {
      case 0: showErrorG0 = value; break;
      case 1: showErrorG1 = value; break;
      case 2: showErrorG2 = value; break;
      case 3: showErrorG3 = value; break;
      case 4: showErrorG4 = value; break;
      case 5: showErrorG5 = value; break;
    }
  }

  void _onNextPressed() {
    setState(() {
      showErrorG0 = showErrorG1 = showErrorG2 = showErrorG3 = showErrorG4 = showErrorG5 = false;
    });
    for (var i = 0; i < subjectGroups.length; i++) {
      if (!_validate(i)) return;
    }
    final Map<int, dynamic> finalSelected = {};
    selectedSubjects.forEach((group, name) {
      final matches = splitSubjects.where((e) => e['key']['field0'] == name).toList();
      if (matches.length == 1) {
        final entry = matches.first;
        finalSelected[group] = {
          'key': entry['key'],
          'value': entry['value'] as String,
        };
      } else {
        finalSelected[group] = name;
      }
    });
    // 1. hasMulti 계산 시 문자열에 포함된 각 과목 검토
    final hasMulti = finalSelected.entries.any((e) {
      if (e.value is String && (e.value as String).contains(',')) {
        for (String subjName in (e.value as String).split(',')) {
          final uniqueValues = splitSubjects
              .where((item) => item['key']['field0'] == subjName)
              .map((item) => item['value'] as String)
              .toSet();
          if (uniqueValues.length > 1) {
            return true;
          }
        }
        return false;
      } else {
        final subjName = e.value is Map<String, dynamic>
            ? ((e.value as Map<String, dynamic>)['key'] as Map<String, dynamic>)['field0'] as String
            : e.value as String;
        final uniqueValues = splitSubjects
            .where((item) => item['key']['field0'] == subjName)
            .map((item) => item['value'] as String)
            .toSet();
        return uniqueValues.length > 1;
      }
    });

    if (!hasMulti) {
      // 2. personalMap 구성 시 문자열에 들어있는 과목들도 처리
      final Map<String, String> personalMap = {};
      finalSelected.forEach((_, v) {
        if (v is Map<String, dynamic>) {
          personalMap[v['key']['field0'] as String] = v['value'] as String;
        } else if (v is String) {
          for (String subjName in v.split(',')) {
            final match = splitSubjects.firstWhere(
              (item) {
                final keyName = item['key']['field0'] as String;
                // strip ASCII 'I' or Unicode 'Ⅱ' roman numerals from subjName
                final baseName = subjName.replaceAll(RegExp(r'[IⅡ]+$'), '');
                return keyName == subjName || keyName == subjName.replaceAll('II','Ⅱ') || keyName.contains(baseName);
              },
              orElse: () => null,
            );
            if (match != null) {
              personalMap[subjName] = match['value'] as String;
            }
          }
        }
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalTimetable(
            grade: widget.grade,
            classNum: widget.classNum,
            selectedSections: personalMap,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SectionDetailPage(
            grade: widget.grade,
            classNum: widget.classNum,
            selectedSubjects: finalSelected,
            splitSubjects: splitSubjects,
          ),
        ),
      );
    }
  }

  bool _validate(int idx) {
    final sel = selectedSubjects[idx];
    if (sel == null) {
      _setErrorFlag(idx, true);
      return false;
    }
    final needed = [3,2,3,1,1,1][idx];
    if (needed > 1 && sel.split(',').length != needed) {
      _setErrorFlag(idx, true);
      return false;
    }
    return true;
  }
}

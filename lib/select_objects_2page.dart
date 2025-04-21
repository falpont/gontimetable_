import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gontimetable/SectionDetailPage.dart';
import 'package:gontimetable/PersonalTimetable.dart';

class SelectObjects2Page extends StatefulWidget {
  final int grade;
  final int classNum;

  const SelectObjects2Page({
    super.key,
    required this.grade,
    required this.classNum,
  });

  @override
  State<SelectObjects2Page> createState() => _SelectObjectsPageState();
}

class _SelectObjectsPageState extends State<SelectObjects2Page> {
  Map<int, String> selectedSubjects = {};
  bool showErrorG0 = false;
  bool showErrorG1 = false;
  bool showErrorG2 = false;

  final List<List<String>> subjectGroups = [
    ['기하', '심화국어', '영어권문화'],
    ['물리학Ⅰ', '사회·문화', '생활과윤리', '생명과학Ⅰ', '지구과학Ⅰ', '화학Ⅰ', '동아시아사', '세계지리'],
    ['인공지능기초', '심리학'],
  ];

  List<dynamic> splitSubjects = [];
  bool isLoading = true;

  Future<void> fetchSplitSubjects() async {
    final url = Uri.parse('http://xn--s39a8pla116tb6t.kro.kr/api/split_subjects/grade${widget.grade}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        splitSubjects = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // handle error
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
        title: const Text("선택과목 선택"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // Section 1: 택1
              Row(
                children: [
                  Text('선택과목 1개 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (showErrorG0)
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
                children: subjectGroups[0].map((subject) {
                  final isSelected = selectedSubjects[0] == subject;
                  return ChoiceChip(
                    label: Text(subject),
                    labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    onSelected: (_) {
                      setState(() {
                        selectedSubjects[0] = subject;
                        showErrorG0 = false;
                      });
                    },
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
              SizedBox(height: 100),

              // Section 2: 택3
              Row(
                children: [
                  Text('선택과목 3개 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (showErrorG1)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('선택하세요', style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: subjectGroups[1]
                        .sublist(0, 3)
                        .map((subject) {
                      final existing = selectedSubjects[1]?.split(',') ?? [];
                      final isSelected = existing.contains(subject);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(subject),
                          labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          selected: isSelected,
                          selectedColor: Colors.black,
                          onSelected: (on) {
                            setState(() {
                              if (isSelected) {
                                existing.remove(subject);
                              } else if (existing.length < 3) {
                                existing.add(subject);
                              }
                              if (existing.isEmpty) {
                                selectedSubjects.remove(1);
                              } else {
                                selectedSubjects[1] = existing.join(',');
                              }
                              showErrorG1 = false;
                            });
                          },
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: subjectGroups[1]
                        .sublist(3, 6)
                        .map((subject) {
                      final existing = selectedSubjects[1]?.split(',') ?? [];
                      final isSelected = existing.contains(subject);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(subject),
                          labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          selected: isSelected,
                          selectedColor: Colors.black,
                          onSelected: (on) {
                            setState(() {
                              if (isSelected) {
                                existing.remove(subject);
                              } else if (existing.length < 3) {
                                existing.add(subject);
                              }
                              if (existing.isEmpty) {
                                selectedSubjects.remove(1);
                              } else {
                                selectedSubjects[1] = existing.join(',');
                              }
                              showErrorG1 = false;
                            });
                          },
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: subjectGroups[1]
                        .sublist(6)
                        .map((subject) {
                      final existing = selectedSubjects[1]?.split(',') ?? [];
                      final isSelected = existing.contains(subject);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(subject),
                          labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          selected: isSelected,
                          selectedColor: Colors.black,
                          onSelected: (on) {
                            setState(() {
                              if (isSelected) {
                                existing.remove(subject);
                              } else if (existing.length < 3) {
                                existing.add(subject);
                              }
                              if (existing.isEmpty) {
                                selectedSubjects.remove(1);
                              } else {
                                selectedSubjects[1] = existing.join(',');
                              }
                              showErrorG1 = false;
                            });
                          },
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 100),

              // Section 3: 택1
              Row(
                children: [
                  Text('선택과목 1개 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (showErrorG2)
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
                children: subjectGroups[2].map((subject) {
                  final isSelected = selectedSubjects[2] == subject;
                  return ChoiceChip(
                    label: Text(subject),
                    labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    onSelected: (_) {
                      setState(() {
                        selectedSubjects[2] = subject;
                        showErrorG2 = false;
                      });
                    },
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
              SizedBox(height: 32),
            ],
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
          onPressed: () {
            setState(() {
              showErrorG0 = false;
              showErrorG1 = false;
              showErrorG2 = false;
            });
            // Validation
            if (selectedSubjects[0] == null) {
              setState(() => showErrorG0 = true);
              return;
            }
            final group2Selection = selectedSubjects[1]?.split(',') ?? [];
            if (group2Selection.length != 3) {
              setState(() => showErrorG1 = true);
              return;
            }
            if (selectedSubjects[2] == null) {
              setState(() => showErrorG2 = true);
              return;
            }

            // Build finalSelected with key+value for single-section, or name for multi
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

            // Determine if any subject needs detailed split selection
            final hasMulti = selectedSubjects.entries.any((e) {
              final uniqueValues = splitSubjects
                  .where((item) => item['key']['field0'] == e.value)
                  .map((item) => item['value'] as String)
                  .toSet();
              return uniqueValues.length > 1;
            });

            if (!hasMulti) {
              // 단일 분반 과목만 PersonalTimetable로 전달
              final Map<String, String> personalMap = {};
              selectedSubjects.forEach((group, name) {
                final val = finalSelected[group];
                if (val is Map<String, dynamic>) {
                  personalMap[name] = val['value'] as String;
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
              // Some subjects need split selection: go to SectionDetailPage
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
          },
          child: const Text("저장하고 계속하기",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

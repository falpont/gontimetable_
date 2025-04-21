import 'package:flutter/material.dart';
import 'package:gontimetable/PersonalTimetable.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SectionDetailPage extends StatefulWidget {
  final int grade;
  final int classNum;
  final Map<int, dynamic> selectedSubjects;
  final List<dynamic> splitSubjects;

  const SectionDetailPage({
    Key? key,
    required this.grade,
    required this.classNum,
    required this.selectedSubjects,
    required this.splitSubjects,
  }) : super(key: key);

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage> {
  late Map<String, String> selectedSections;
  late List<String> subjectList;
  bool isLoadingSections = true;
  Map<String, List<Map<String, dynamic>>> availableSections = {};

  @override
  void initState() {
    super.initState();

    // Build flat subject list from selectedSubjects using field0 (actual name)
    subjectList = [];
    widget.selectedSubjects.forEach((idx, val) {
      if (val is String) {
        subjectList.addAll(val.split(','));
      } else if (val is Map<String, dynamic>) {
        subjectList.add(val['key']['field0'] as String);
      }
    });

    // Initialize selections map
    selectedSections = { for (var name in subjectList) name: '' };

    // Build availableSections with unique values per subject name
    final Map<String, Map<String, String>> tempMap = {};
    for (var e in widget.splitSubjects) {
      final keyMap = e['key'] as Map<String, dynamic>;
      final name = keyMap['field0'] as String;
      final teacher = keyMap['field3'] as String;
      final classNo = keyMap['field4'] as int;
      String location;
      if (classNo >= 1 && classNo <= 6) {
        location = '${classNo}반';
      } else if (classNo == 7) {
        location = '선택과목실';
      } else if (classNo == 8) {
        location = '선택과목실2';
      } else {
        location = '';
      }
      final value = e['value'] as String;
      final label = '$teacher 선생님, ${widget.grade}학년 $location $value';
      tempMap.putIfAbsent(name, () => {});
      if (!tempMap[name]!.containsKey(value)) {
        tempMap[name]![value] = label;
      }
    }
    availableSections = {
      for (var entry in tempMap.entries)
        entry.key: entry.value.entries
          .map((kv) => {'label': kv.value, 'value': kv.key})
          .toList()
    };

    // Auto-select single-option subjects
    for (var name in subjectList) {
      final opts = availableSections[name] ?? [];
      if (opts.length == 1) {
        selectedSections[name] = opts.first['value'] as String;
      }
    }

    isLoadingSections = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.grade}학년 ${widget.classNum}반 과목 분반 선택',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: isLoadingSections
        ? Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...subjectList
                .where((subject) => (availableSections[subject] ?? []).length > 1)
                .map((subject) {
                  final sections = availableSections[subject]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '분반 선택',
                            border: OutlineInputBorder(),
                          ),
                          items: sections.map((opt) => DropdownMenuItem<String>(
                            value: opt['value'] as String,
                            child: Text(opt['label'] as String),
                          )).toList(),
                          value: selectedSections[subject]?.isEmpty ?? true
                            ? null
                            : selectedSections[subject],
                          onChanged: (value) {
                            setState(() {
                              selectedSections[subject] = value ?? '';
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            // Persist selection
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('savedGrade', widget.grade);
            await prefs.setInt('savedClass', widget.classNum);
            await prefs.setString('savedSelectedSections', json.encode(selectedSections));
            // Validation
            for (var subject in subjectList) {
              final secs = availableSections[subject] ?? [];
              if (secs.length > 1 && (selectedSections[subject]?.isEmpty ?? true)) {
                return;
              }
            }
            // Navigate to personal timetable
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PersonalTimetable(
                  grade: widget.grade,
                  classNum: widget.classNum,
                  selectedSections: Map.fromEntries(
                    selectedSections.entries.where((e) {
                      final opts = availableSections[e.key] ?? [];
                      return opts.isNotEmpty && (opts.length == 1 || e.value.isNotEmpty);
                    }),
                  ),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('완료', style: TextStyle(color: Colors.white,fontSize: 18),),
        ),
      ),
    );
  }
}
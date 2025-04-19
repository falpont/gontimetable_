import 'package:flutter/material.dart';

class SelectObjectsPage extends StatefulWidget {
  final int grade;
  final int classNum;

  const SelectObjectsPage({
    super.key,
    required this.grade,
    required this.classNum,
  });

  @override
  State<SelectObjectsPage> createState() => _SelectObjectsPageState();
}

class _SelectObjectsPageState extends State<SelectObjectsPage> {
  // 선택된 과목 저장용 (그룹 별 1개만 선택 가능한 경우)
  Map<int, String> selectedSubjects = {};

  // 예시 과목 그룹들 (택1인 그룹)
  final List<List<String>> subjectGroups = [
    ['심국', '기하', '영어문화'],
    ['중어', '일어', '한문'],
    ['심리', '인기', '문화예술체험', '영상감상과비평'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("선택과목 선택"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjectGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = subjectGroups[groupIndex];
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: group.map((subject) {
                  final isSelected = selectedSubjects[groupIndex] == subject;
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedSubjects[groupIndex] = subject;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.black : Colors.white,
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Colors.black),
                        minimumSize: const Size(80, 50),
                      ),
                      child: Text(subject, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            // 선택된 과목 처리 로직
            print("선택된 과목: \$selectedSubjects");
          },
          child: const Text("저장하고 계속하기", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
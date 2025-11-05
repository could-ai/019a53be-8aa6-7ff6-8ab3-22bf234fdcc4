import 'package:flutter/material.dart';
import 'services/attendance_service.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AttendancePage(),
      },
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceService _attendanceService = AttendanceService();
  List<String> _students = [];
  Map<String, bool> _attendance = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads students and their attendance from the local storage.
  Future<void> _loadData() async {
    final students = await _attendanceService.loadStudents();
    final attendanceMap = <String, bool>{};
    for (var student in students) {
      final present = await _attendanceService.loadAttendance(student);
      attendanceMap[student] = present;
    }
    setState(() {
      _students = students;
      _attendance = attendanceMap;
      _loading = false;
    });
  }

  /// Toggles the attendance state for a student, updates UI and persists the change.
  void _toggleAttendance(String student, bool? value) {
    final isPresent = value ?? false;
    setState(() {
      _attendance[student] = isPresent;
    });
    _attendanceService.saveAttendance(student, isPresent);
  }

  /// Opens a dialog to add a new student to the class list.
  void _addStudent() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter student name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty && !_students.contains(name)) {
                  setState(() {
                    _students.add(name);
                    _attendance[name] = false;
                  });
                  _attendanceService.saveStudents(_students);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Attendance'),
        actions: [
          IconButton(
            onPressed: _addStudent,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No students. Add students to begin.'))
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final present = _attendance[student] ?? false;
                    return CheckboxListTile(
                      title: Text(student),
                      value: present,
                      onChanged: (value) {
                        _toggleAttendance(student, value);
                      },
                    );
                  },
                ),
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage persistent storage of students list and attendance flags.
class AttendanceService {
  static const String _studentsKey = 'students';

  /// Loads the list of students from SharedPreferences.
  Future<List<String>> loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_studentsKey) ?? [];
  }

  /// Saves the list of students to SharedPreferences.
  Future<void> saveStudents(List<String> students) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_studentsKey, students);
  }

  /// Loads the attendance flag for a specific student.
  Future<bool> loadAttendance(String student) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('attendance_$student') ?? false;
  }

  /// Saves the attendance flag for a specific student.
  Future<void> saveAttendance(String student, bool present) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('attendance_$student', present);
  }
}
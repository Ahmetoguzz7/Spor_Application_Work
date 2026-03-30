
class Attendance {
  final String attendanceId;
  final String studentId;
  final String date;
  final String status;
  final String notes;

  Attendance({
    required this.attendanceId,
    required this.studentId,
    required this.date,
    required this.status,
    required this.notes,
  });

  // Sheets'ten gelen JSON'u modele çevirir
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendance_id'].toString(),
      studentId: json['student_id'].toString(),
      date: json['date'].toString(),
      status: json['status'].toString(),
      notes: json['notes'].toString(),
    );
  }

  // Modeli Sheets'e göndermek için JSON'a çevirir
  Map<String, dynamic> toJson() => {
    'attendance_id': attendanceId,
    'student_id': studentId,
    'date': date,
    'status': status,
    'notes': notes,
  };
}
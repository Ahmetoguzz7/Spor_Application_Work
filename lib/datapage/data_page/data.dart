class Student {
  final String studentId;
  final String userId;
  final int age;
  final String parentId;
  final String branchId;
  final String sportId;
  final String enrollmentDate;

  Student({
    required this.studentId, required this.userId, required this.age,
    required this.parentId, required this.branchId, required this.sportId,
    required this.enrollmentDate,
  });

  // JSON'dan nesneye (Okuma için)
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'].toString(),
      userId: json['user_id'].toString(),
      age: int.tryParse(json['age'].toString()) ?? 0,
      parentId: json['parent_id'].toString(),
      branchId: json['branch_id'].toString(),
      sportId: json['sport_id'].toString(),
      enrollmentDate: json['enrollment_date'].toString(),
    );
  }

  // Nesneden JSON'a (Sheets'e göndermek için)
  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'user_id': userId,
    'age': age,
    'parent_id': parentId,
    'branch_id': branchId,
    'sport_id': sportId,
    'enrollment_date': enrollmentDate,
  };
}
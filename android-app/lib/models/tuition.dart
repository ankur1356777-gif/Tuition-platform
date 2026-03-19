class PaidTuition {
  final int id;
  final int teacherId;
  final int studentId;
  final String subjects;
  final String status;
  final double monthlyFee;
  final String? studentName;

  PaidTuition({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.subjects,
    required this.status,
    required this.monthlyFee,
    this.studentName,
  });

  factory PaidTuition.fromJson(Map<String, dynamic> json) {
    return PaidTuition(
      id: json['id'],
      teacherId: json['teacher_id'],
      studentId: json['student_id'],
      subjects: json['subjects']?.toString() ?? '',
      status: json['status'],
      monthlyFee: (json['monthly_fee'] ?? 0).toDouble(),
      studentName: json['student']?['user']?['name'],
    );
  }
}

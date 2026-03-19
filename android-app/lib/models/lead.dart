class Lead {
  final int id;
  final int teacherId;
  final int tuitionRequestId;
  final String status;
  final String? distanceKm;
  final String? matchScore;
  final DateTime createdAt;
  final TuitionRequest? tuitionRequest;

  Lead({
    required this.id,
    required this.teacherId,
    required this.tuitionRequestId,
    required this.status,
    this.distanceKm,
    this.matchScore,
    required this.createdAt,
    this.tuitionRequest,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      teacherId: json['teacher_id'],
      tuitionRequestId: json['tuition_request_id'],
      status: json['status'],
      distanceKm: json['distance_km']?.toString(),
      matchScore: json['match_score']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
      tuitionRequest: json['tuition_request'] != null 
          ? TuitionRequest.fromJson(json['tuition_request']) 
          : null,
    );
  }
}

class TuitionRequest {
  final int id;
  final int studentId;
  final dynamic subjects;
  final String grade;
  final String location;
  final String status;

  TuitionRequest({
    required this.id,
    required this.studentId,
    required this.subjects,
    required this.grade,
    required this.location,
    required this.status,
  });

  factory TuitionRequest.fromJson(Map<String, dynamic> json) {
    return TuitionRequest(
      id: json['id'],
      studentId: json['student_id'],
      subjects: json['subjects'],
      grade: json['grade'] ?? json['class'] ?? '',
      location: json['location'] ?? json['address'] ?? '',
      status: json['status'],
    );
  }

  String get subjectsString {
    if (subjects is List) {
      return (subjects as List).join(', ');
    }
    return subjects.toString();
  }
}

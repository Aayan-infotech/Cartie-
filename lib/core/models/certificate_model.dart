class Certificate {
  final String id;
  final String userId;
  final String locationId;
  final String certificateNumber;
  final String email;
  final String certificateName;
  final String certificateIssuedBy;
  final DateTime issueDate;
  final String certificateUrl;
  final DateTime validUntil;
  final DateTime issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.certificateNumber,
    required this.email,
    required this.certificateName,
    required this.certificateIssuedBy,
    required this.issueDate,
    required this.certificateUrl,
    required this.validUntil,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id'],
      userId: json['userId'],
      locationId: json['locationId'],
      certificateNumber: json['certificateNumber'],
      email: json['email'],
      certificateName: json['certificateName'],
      certificateIssuedBy: json['certificateIssuedBy'],
      issueDate: DateTime.parse(json['issueDate']),
      certificateUrl: json['certificateUrl'],
      validUntil: DateTime.parse(json['validUntil']),
      issuedAt: DateTime.parse(json['issuedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'locationId': locationId,
      'certificateNumber': certificateNumber,
      'email': email,
      'certificateName': certificateName,
      'certificateIssuedBy': certificateIssuedBy,
      'issueDate': issueDate.toIso8601String(),
      'certificateUrl': certificateUrl,
      'validUntil': validUntil.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

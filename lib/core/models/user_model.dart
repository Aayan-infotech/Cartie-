class UserModel {
   String name;
  final String email;
  final String mobile;
   String address;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String refreshToken;

  UserModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.now(), // DateTime.parse(json['createdAt']),
      updatedAt: DateTime.now(), //DateTime.parse(json['updatedAt']),
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'refreshToken': refreshToken,
    };
  }
}

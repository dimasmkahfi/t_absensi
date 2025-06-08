class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String department;
  final String position;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.department,
    required this.position,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'department': department,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

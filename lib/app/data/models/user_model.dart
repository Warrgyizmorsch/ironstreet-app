class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String memberStatus;
  final String joinedDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.memberStatus,
    required this.joinedDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      memberStatus: json['memberStatus'] ?? 'Standard Member',
      joinedDate: json['joinedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'memberStatus': memberStatus,
      'joinedDate': joinedDate,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? memberStatus,
    String? joinedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      memberStatus: memberStatus ?? this.memberStatus,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

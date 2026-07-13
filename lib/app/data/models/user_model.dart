class UserModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String profileImage;
  final String memberStatus;
  final String joinedDate;
  final List<String> roles;
  final String registeredDate;

  UserModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.memberStatus,
    required this.joinedDate,
    this.roles = const [],
    this.registeredDate = '',
  });

  /// Maps the WordPress REST API `/wp/v2/users/me` response.
  /// Field reference:
  ///   id              → id
  ///   name            → display name
  ///   first_name      → firstName
  ///   last_name       → lastName
  ///   email           → email
  ///   url             → profileImage (avatar URL stored in user URL field)
  ///   roles           → roles list
  ///   registered_date → registeredDate (ISO 8601)
  factory UserModel.fromWpJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : '';

    final rawRoles = json['roles'];
    final List<String> roles =
        rawRoles is List ? rawRoles.map((r) => r.toString()).toList() : [];

    final registeredDate = json['registered_date'] as String? ?? '';
    final joinedLabel = _formatJoinedDate(registeredDate);

    final memberStatus = roles.contains('administrator')
        ? 'Administrator'
        : roles.contains('shop_manager')
            ? 'Shop Manager'
            : 'Member';

    return UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: '',
      profileImage: json['url'] as String? ?? '',
      memberStatus: memberStatus,
      joinedDate: joinedLabel,
      roles: roles,
      registeredDate: registeredDate,
    );
  }

  /// Legacy fromJson kept for backward compatibility.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      memberStatus: json['memberStatus'] as String? ?? 'Member',
      joinedDate: json['joinedDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'memberStatus': memberStatus,
      'joinedDate': joinedDate,
      'roles': roles,
      'registeredDate': registeredDate,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    String? memberStatus,
    String? joinedDate,
    List<String>? roles,
    String? registeredDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      memberStatus: memberStatus ?? this.memberStatus,
      joinedDate: joinedDate ?? this.joinedDate,
      roles: roles ?? this.roles,
      registeredDate: registeredDate ?? this.registeredDate,
    );
  }

  /// Converts ISO 8601 registered_date → "Joined July 2026"
  static String _formatJoinedDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return 'Joined ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

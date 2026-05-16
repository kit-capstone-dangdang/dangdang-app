class User {
  final String uid;
  final String name;
  final String nickname;
  final String email;
  final DateTime? createdAt;

  const User({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.email,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final int? age;
  final String? gender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.age,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'age': age,
        'gender': gender,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    int? age,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, age, gender];
}

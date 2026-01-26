import 'package:real_amis/domain/entities/auth/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.email, required super.isAdmin});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'isAdmin': isAdmin};
  }

  UserModel copyWith({String? id, String? email, bool? isAdmin}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

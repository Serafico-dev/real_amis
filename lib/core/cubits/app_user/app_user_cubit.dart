import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:real_amis/data/models/auth/user_model.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';

part 'app_user_state.dart';

class AppUserCubit extends HydratedCubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(UserEntity? user) {
    if (user == null) {
      emit(AppUserLoggedOut());
    } else {
      emit(AppUserLoggedIn(user));
    }
  }

  void clearUser() {
    emit(AppUserLoggedOut());
  }

  @override
  AppUserState? fromJson(Map<String, dynamic> json) {
    try {
      final userJson = json['user'];
      if (userJson == null) return AppUserInitial();

      final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

      return AppUserLoggedIn(user);
    } catch (_) {
      return AppUserInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AppUserState state) {
    if (state is AppUserLoggedIn) {
      final user = state.user;
      if (user is UserModel) {
        return {'user': user.toJson()};
      }

      return {
        'user': {'id': user.id, 'email': user.email, 'isAdmin': user.isAdmin},
      };
    }
    return null;
  }
}

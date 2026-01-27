import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:real_amis/data/models/auth/user_model.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';
import 'package:real_amis/domain/entities/auth/user_entity.dart';

class AppUserCubit extends HydratedCubit<AppUserState> {
  final AuthSupabaseDataSource authDataSource;

  AppUserCubit(this.authDataSource) : super(AppUserInitial());

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

  Future<void> refreshUser() async {
    try {
      final userData = await authDataSource.getCurrentUserData();
      if (userData != null) {
        updateUser(userData);
      }
    } catch (_) {}
  }

  @override
  AppUserState? fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson == null) return AppUserInitial();
    final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));
    return AppUserLoggedIn(user);
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

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final UserEntity user;
  AppUserLoggedIn(this.user);
}

class AppUserLoggedOut extends AppUserState {}

import 'dart:convert';

import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/utils/secure_storage.dart';
import 'package:real_amis/data/models/auth/user_model.dart';
import 'package:real_amis/init_dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthSupabaseDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel> logInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();

  Future<void> logOut();

  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  });

  Future<void> updatePassword({required String newPassword});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount({required String id});
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  final SupabaseClient supabaseClient;
  AuthSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
      );
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        final sessionJson = jsonEncode(session.toJson());
        await serviceLocator<SecureStorage>().saveSession(sessionJson);
      }
      if (response.user == null) {
        throw ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromJson(
          userData.first,
        ).copyWith(email: currentUserSession!.user.email);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await supabaseClient.auth.signOut(scope: SignOutScope.global);
      await serviceLocator<SecureStorage>().clearAll();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = supabaseClient.auth.currentSession;
    if (session == null || session.user.email == null) {
      throw ServerException('Utente non autenticato');
    }

    await supabaseClient.auth.signInWithPassword(
      email: session.user.email!,
      password: currentPassword,
    );

    await supabaseClient.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> deleteAccount({required String id}) async {
    try {
      await supabaseClient.auth.admin.deleteUser(id);
      await serviceLocator<SecureStorage>().clearAll();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

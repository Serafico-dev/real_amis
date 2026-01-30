import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';
import 'package:real_amis/presentation/auth/providers/app_user_notifier.dart';

final appUserProvider =
    StateNotifierProvider<AppUserNotifier, AsyncValue<AppUserState>>(
      (ref) => AppUserNotifier(ref.read(authSupabaseDataSourceProvider)),
    );

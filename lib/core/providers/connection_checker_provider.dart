import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:real_amis/core/network/connection_checker.dart';

final internetConnectionProvider = Provider<InternetConnection>((ref) {
  return InternetConnection();
});

final connectionCheckerProvider = Provider<ConnectionChecker>((ref) {
  return ConnectionCheckerImpl(ref.read(internetConnectionProvider));
});

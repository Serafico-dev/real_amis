import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final hiveBoxProvider = Provider<Box>((ref) {
  const boxName = 'userBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare initDependencies() prima di leggere il provider.",
    );
  }
  return Hive.box(boxName);
});

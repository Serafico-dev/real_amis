import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/data/repositories/match/match_repository_impl.dart';
import 'package:real_amis/domain/usecases/match/delete_match.dart';
import 'package:real_amis/domain/usecases/match/get_all_matches.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';

final uploadMatchProvider = Provider<UploadMatch>((ref) {
  return UploadMatch(ref.read(matchRepositoryProvider));
});
final updateMatchProvider = Provider<UpdateMatch>((ref) {
  return UpdateMatch(ref.read(matchRepositoryProvider));
});
final deleteMatchProvider = Provider<DeleteMatch>((ref) {
  return DeleteMatch(ref.read(matchRepositoryProvider));
});
final getAllMatchesProvider = Provider<GetAllMatches>((ref) {
  return GetAllMatches(ref.read(matchRepositoryProvider));
});

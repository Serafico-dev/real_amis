import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/data/repositories/event/event_repository_impl.dart';
import 'package:real_amis/domain/usecases/event/delete_event.dart';
import 'package:real_amis/domain/usecases/event/get_all_events.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/event/update_event.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';

final uploadEventProvider = Provider<UploadEvent>((ref) {
  return UploadEvent(ref.read(eventRepositoryProvider));
});
final updateEventProvider = Provider<UpdateEvent>((ref) {
  return UpdateEvent(ref.read(eventRepositoryProvider));
});
final deleteEventProvider = Provider<DeleteEvent>((ref) {
  return DeleteEvent(ref.read(eventRepositoryProvider));
});
final getAllEventsProvider = Provider<GetAllEvents>((ref) {
  return GetAllEvents(ref.read(eventRepositoryProvider));
});
final getEventsByMatchProvider = Provider<GetEventsByMatch>((ref) {
  return GetEventsByMatch(ref.read(eventRepositoryProvider));
});

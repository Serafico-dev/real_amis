import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/event/event_model.dart';

/// Provider sicuro della box Hive
final eventBoxProvider = Provider<Box>((ref) {
  const boxName = 'eventsBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

/// Interfaccia per il local data source degli eventi
abstract interface class EventLocalDataSource {
  void uploadLocalEvents({required List<EventModel> events});
  List<EventModel> loadEvents();
}

/// Provider del local data source
final eventLocalDataSourceProvider = Provider<EventLocalDataSource>((ref) {
  return EventLocalDataSourceImpl(ref.read(eventBoxProvider));
});

/// Implementazione concreta del local data source
class EventLocalDataSourceImpl implements EventLocalDataSource {
  final Box box;

  EventLocalDataSourceImpl(this.box);

  @override
  List<EventModel> loadEvents() {
    final List<EventModel> events = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        events.add(EventModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return events;
  }

  @override
  void uploadLocalEvents({required List<EventModel> events}) {
    box.clear();
    for (int i = 0; i < events.length; i++) {
      box.put(i.toString(), events[i].toJson());
    }
  }
}

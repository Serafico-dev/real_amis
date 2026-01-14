import 'package:hive/hive.dart';
import 'package:real_amis/data/models/event/event_model.dart';

abstract interface class EventLocalDataSource {
  void uploadLocalEvents({required List<EventModel> events});
  List<EventModel> loadEvents();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final Box box;
  EventLocalDataSourceImpl(this.box);

  @override
  List<EventModel> loadEvents() {
    List<EventModel> events = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        events.add(EventModel.fromJson(box.get(i.toString())));
      }
    });
    return events;
  }

  @override
  void uploadLocalEvents({required List<EventModel> events}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < events.length; i++) {
        box.put(i.toString(), events[i].toJson());
      }
    });
  }
}

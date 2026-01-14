import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/event/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class EventSupabaseDataSource {
  Future<EventModel> uploadEvent(EventModel event);
  Future<List<EventModel>> getAllEvents();
  Future<EventModel> updateEvent(EventModel event);
  Future<EventModel> deleteEvent({required String eventId});
}

class EventSupabaseDataSourceImpl implements EventSupabaseDataSource {
  final SupabaseClient supabaseClient;
  EventSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<EventModel> uploadEvent(EventModel event) async {
    try {
      final eventData = await supabaseClient
          .from('events')
          .insert(event.toJson())
          .select();
      return EventModel.fromJson(eventData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<EventModel>> getAllEvents() async {
    try {
      final events = await supabaseClient
          .from('events')
          .select('*, team:team_id(name,image_url)');
      return events.map((event) => EventModel.fromJson(event)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final eventData = await supabaseClient
          .from('events')
          .update(event.toJson())
          .eq('id', event.id)
          .select();
      return EventModel.fromJson(eventData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<EventModel> deleteEvent({required String eventId}) async {
    try {
      await supabaseClient.storage.from('events').remove([eventId]);
      final eventData = await supabaseClient
          .from('events')
          .delete()
          .eq('id', eventId)
          .select();
      return EventModel.fromJson(eventData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

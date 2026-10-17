import '../../models/event_model.dart';

abstract class EventDataSource {
  Future<List<EventModel>> getAll();
  Future<EventModel?> getById(String id);
  Future<String?> getCurrentEventId();
  Future<void> setCurrentEventId(String eventId);
  Future<EventModel> create(EventModel event);
  Future<EventModel> update(EventModel event);
  Future<void> delete(String id);
}

import '../../core/constants/hive_constants.dart';
import '../../models/event_model.dart';
import '../abstract/event_data_source.dart';
import '../../storage/storage_service.dart';

class HiveEventDataSource implements EventDataSource {
  HiveEventDataSource(this._storage);

  final StorageService _storage;

  @override
  Future<List<EventModel>> getAll() async {
    return _storage.events.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<EventModel?> getById(String id) async => _storage.events.get(id);

  @override
  Future<String?> getCurrentEventId() async {
    return _storage.meta.get(MetaKeys.currentEventId) as String?;
  }

  @override
  Future<void> setCurrentEventId(String eventId) async {
    await _storage.meta.put(MetaKeys.currentEventId, eventId);
  }

  @override
  Future<EventModel> create(EventModel event) async {
    await _storage.events.put(event.id, event);
    return event;
  }

  @override
  Future<EventModel> update(EventModel event) async {
    await _storage.events.put(event.id, event);
    return event;
  }

  @override
  Future<void> delete(String id) async {
    await _storage.events.delete(id);
    final current = await getCurrentEventId();
    if (current == id) {
      await _storage.meta.delete(MetaKeys.currentEventId);
    }
  }
}

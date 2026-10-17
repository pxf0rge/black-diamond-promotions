import 'package:uuid/uuid.dart';

import '../core/errors/app_exception.dart';
import '../datasources/abstract/event_data_source.dart';
import '../models/event_model.dart';

class EventRepository {
  EventRepository(this._dataSource, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final EventDataSource _dataSource;
  final Uuid _uuid;

  Future<List<EventModel>> getAllEvents() => _dataSource.getAll();

  Future<EventModel?> getEventById(String id) => _dataSource.getById(id);

  Future<EventModel?> getCurrentEvent() async {
    final id = await _dataSource.getCurrentEventId();
    if (id == null) return null;
    return _dataSource.getById(id);
  }

  Future<EventModel> createEvent({
    required String name,
    required String location,
    required String description,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final event = EventModel(
      id: _uuid.v4(),
      name: name.trim(),
      location: location.trim(),
      description: description.trim(),
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    return _dataSource.create(event);
  }

  Future<EventModel> updateEvent(EventModel event) async {
    if (event.name.trim().isEmpty) {
      throw const ValidationException('Event name cannot be empty');
    }
    return _dataSource.update(event.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteEvent(String id) async {
    final currentId = await _dataSource.getCurrentEventId();
    await _dataSource.delete(id);
    if (currentId != id) return;

    final remaining = await _dataSource.getAll();
    if (remaining.isEmpty) return;
    await _dataSource.setCurrentEventId(remaining.first.id);
  }

  Future<void> switchEvent(String eventId) async {
    final event = await _dataSource.getById(eventId);
    if (event == null) {
      throw const ValidationException('Event not found');
    }
    await _dataSource.setCurrentEventId(eventId);
  }
}

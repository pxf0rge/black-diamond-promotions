import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  EventProvider({required EventRepository eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository _eventRepository;

  EventModel? _currentEvent;
  List<EventModel> _events = [];
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _errorMessage;

  EventModel? get currentEvent => _currentEvent;
  List<EventModel> get events => _events;
  bool get isSaving => _isSaving;
  bool get saveSuccess => _saveSuccess;
  String? get errorMessage => _errorMessage;

  Future<void> init() => _reload();

  Future<void> _reload() async {
    _events = await _eventRepository.getAllEvents();
    _currentEvent = await _eventRepository.getCurrentEvent();
    notifyListeners();
  }

  void updateLocal({
    String? name,
    String? location,
    DateTime? date,
    String? description,
  }) {
    if (_currentEvent == null) return;
    _currentEvent = _currentEvent!.copyWith(
      name: name,
      location: location,
      date: date,
      description: description,
    );
    notifyListeners();
  }

  Future<void> saveEvent() async {
    if (_currentEvent == null) return;
    _isSaving = true;
    _saveSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentEvent = await _eventRepository.updateEvent(_currentEvent!);
      _saveSuccess = true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to save event';
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    if (_saveSuccess) {
      await Future.delayed(const Duration(seconds: 2));
      _saveSuccess = false;
      notifyListeners();
    }
  }

  Future<bool> switchEvent(String eventId) async {
    if (_currentEvent?.id == eventId) return true;
    try {
      await _eventRepository.switchEvent(eventId);
      await _reload();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Creates a new event and switches to it.
  Future<bool> createEvent({
    required String name,
    required String location,
    required String description,
    required DateTime date,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final event = await _eventRepository.createEvent(
        name: name,
        location: location,
        description: description,
        date: date,
      );
      await _eventRepository.switchEvent(event.id);
      await _reload();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to create event';
      notifyListeners();
      return false;
    }
  }

  /// Kept for backwards compatibility with first-time setup UI.
  Future<bool> createFirstEvent({
    required String name,
    required String location,
    required String description,
    required DateTime date,
  }) => createEvent(
    name: name,
    location: location,
    description: description,
    date: date,
  );

  Future<bool> deleteEvent(String eventId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _eventRepository.deleteEvent(eventId);
      await _reload();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to delete event';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

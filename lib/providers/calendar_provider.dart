import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum EventType { study, exam, assignment, personal, meeting }

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final Color color;
  final bool isAllDay;
  final String? location;
  final List<String> reminders; // Minutes before event
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.color,
    this.isAllDay = false,
    this.location,
    this.reminders = const [],
    required this.createdAt,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      type: EventType.values[data['type'] ?? 0],
      color: Color(data['color'] ?? Colors.blue.value),
      isAllDay: data['isAllDay'] ?? false,
      location: data['location'],
      reminders: List<String>.from(data['reminders'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type.index,
      'color': color.value,
      'isAllDay': isAllDay,
      'location': location,
      'reminders': reminders,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CalendarEvent copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    Color? color,
    bool? isAllDay,
    String? location,
    List<String>? reminders,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt,
    );
  }
}

class CalendarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  List<CalendarEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CalendarEvent> get selectedDateEvents {
    return _events.where((event) {
      return event.startTime.year == _selectedDate.year &&
             event.startTime.month == _selectedDate.month &&
             event.startTime.day == _selectedDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) {
      return event.startTime.isAfter(now);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  CalendarProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadEvents();
      } else {
        _events.clear();
        notifyListeners();
      }
    });
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .orderBy('startTime')
          .get();

      _events = snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required EventType type,
    required Color color,
    bool isAllDay = false,
    String? location,
    List<String> reminders = const [],
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final event = CalendarEvent(
        id: '',
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        type: type,
        color: color,
        isAllDay: isAllDay,
        location: location,
        reminders: reminders,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .add(event.toFirestore());

      await loadEvents();
      return true;
    } catch (e) {
      _error = 'Failed to add event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    Color? color,
    bool? isAllDay,
    String? location,
    List<String>? reminders,
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex == -1) return false;

      final event = _events[eventIndex];
      final updatedEvent = event.copyWith(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        type: type,
        color: color,
        isAllDay: isAllDay,
        location: location,
        reminders: reminders,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId)
          .update(updatedEvent.toFirestore());

      _events[eventIndex] = updatedEvent;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId)
          .delete();

      _events.removeWhere((event) => event.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete event: $e';
      notifyListeners();
      return false;
    }
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.startTime.year == day.year &&
             event.startTime.month == day.month &&
             event.startTime.day == day.day;
    }).toList();
  }

  bool hasEventsOnDay(DateTime day) {
    return getEventsForDay(day).isNotEmpty;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Predefined colors for events
  static const List<Color> eventColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  // Get color for event type
  static Color getColorForEventType(EventType type) {
    switch (type) {
      case EventType.study:
        return Colors.blue;
      case EventType.exam:
        return Colors.red;
      case EventType.assignment:
        return Colors.orange;
      case EventType.personal:
        return Colors.green;
      case EventType.meeting:
        return Colors.purple;
    }
  }

  // Get icon for event type
  static IconData getIconForEventType(EventType type) {
    switch (type) {
      case EventType.study:
        return Icons.book;
      case EventType.exam:
        return Icons.quiz;
      case EventType.assignment:
        return Icons.assignment;
      case EventType.personal:
        return Icons.person;
      case EventType.meeting:
        return Icons.people;
    }
  }
}
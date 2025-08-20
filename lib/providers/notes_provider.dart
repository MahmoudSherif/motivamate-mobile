import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum NoteCategory { personal, study, work, ideas, other }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final Color color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    required this.color,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: NoteCategory.values[data['category'] ?? 0],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPinned: data['isPinned'] ?? false,
      color: Color(data['color'] ?? Colors.amber.value),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category.index,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'color': color.value,
    };
  }

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    List<String>? tags,
    DateTime? updatedAt,
    bool? isPinned,
    Color? color,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
    );
  }

  String get preview {
    if (content.isEmpty) return 'No content';
    return content.length > 100 
        ? '${content.substring(0, 100)}...'
        : content;
  }
}

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  String _searchQuery = '';
  NoteCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _getFilteredNotes();
  List<Note> get allNotes => _notes;
  String get searchQuery => _searchQuery;
  NoteCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Note> get pinnedNotes {
    return _notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Note> get recentNotes {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _notes.where((note) => note.updatedAt.isAfter(sevenDaysAgo)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  NotesProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadNotes();
      } else {
        _notes.clear();
        notifyListeners();
      }
    });
  }

  List<Note> _getFilteredNotes() {
    List<Note> filtered = List.from(_notes);

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((note) => note.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
               note.content.toLowerCase().contains(query) ||
               note.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Sort: pinned first, then by updated date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(NoteCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .orderBy('updatedAt', descending: true)
          .get();

      _notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addNote({
    required String title,
    required String content,
    required NoteCategory category,
    List<String> tags = const [],
    Color? color,
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final now = DateTime.now();
      final note = Note(
        id: '',
        title: title,
        content: content,
        category: category,
        tags: tags,
        createdAt: now,
        updatedAt: now,
        color: color ?? noteColors[0],
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .add(note.toFirestore());

      await loadNotes();
      return true;
    } catch (e) {
      _error = 'Failed to add note: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(String noteId, {
    String? title,
    String? content,
    NoteCategory? category,
    List<String>? tags,
    bool? isPinned,
    Color? color,
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex == -1) return false;

      final note = _notes[noteIndex];
      final updatedNote = note.copyWith(
        title: title,
        content: content,
        category: category,
        tags: tags,
        updatedAt: DateTime.now(),
        isPinned: isPinned,
        color: color,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(noteId)
          .update(updatedNote.toFirestore());

      _notes[noteIndex] = updatedNote;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update note: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete note: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePinNote(String noteId) async {
    final note = _notes.firstWhere((n) => n.id == noteId);
    return await updateNote(noteId, isPinned: !note.isPinned);
  }

  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  int getNotesCountByCategory(NoteCategory category) {
    return _notes.where((note) => note.category == category).length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Predefined colors for notes
  static const List<Color> noteColors = [
    Color(0xFFFFF59D), // Light Yellow
    Color(0xFFFFCC80), // Light Orange
    Color(0xFFFFAB91), // Light Deep Orange
    Color(0xFFF8BBD9), // Light Pink
    Color(0xFFE1BEE7), // Light Purple
    Color(0xFFC5CAE9), // Light Indigo
    Color(0xFFBBDEFB), // Light Blue
    Color(0xFFB2EBF2), // Light Cyan
    Color(0xFFB2DFDB), // Light Teal
    Color(0xFFC8E6C9), // Light Green
    Color(0xFFDCEDC8), // Light Light Green
    Color(0xFFF0F4C3), // Light Lime
  ];

  // Get icon for note category
  static IconData getIconForCategory(NoteCategory category) {
    switch (category) {
      case NoteCategory.personal:
        return Icons.person;
      case NoteCategory.study:
        return Icons.school;
      case NoteCategory.work:
        return Icons.work;
      case NoteCategory.ideas:
        return Icons.lightbulb;
      case NoteCategory.other:
        return Icons.note;
    }
  }

  // Get label for note category
  static String getLabelForCategory(NoteCategory category) {
    switch (category) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.study:
        return 'Study';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.ideas:
        return 'Ideas';
      case NoteCategory.other:
        return 'Other';
    }
  }
}
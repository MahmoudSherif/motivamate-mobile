import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

enum TaskPriority { low, medium, high }

enum ChallengeStatus { active, completed, expired }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? challengeId;
  final int points;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.challengeId,
    this.points = 10,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: TaskPriority.values[data['priority'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      challengeId: data['challengeId'],
      points: data['points'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'challengeId': challengeId,
      'points': points,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    String? challengeId,
    int? points,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      challengeId: challengeId ?? this.challengeId,
      points: points ?? this.points,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String code;
  final String adminId;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime endDate;
  final ChallengeStatus status;
  final Map<String, int> participantScores;
  final List<Task> tasks;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.adminId,
    required this.participantIds,
    required this.createdAt,
    required this.endDate,
    required this.status,
    required this.participantScores,
    required this.tasks,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      code: data['code'] ?? '',
      adminId: data['adminId'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: ChallengeStatus.values[data['status'] ?? 0],
      participantScores: Map<String, int>.from(data['participantScores'] ?? {}),
      tasks: [], // Tasks are loaded separately
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'adminId': adminId,
      'participantIds': participantIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.index,
      'participantScores': participantScores,
    };
  }
}

class TasksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _personalTasks = [];
  List<Challenge> _challenges = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get personalTasks => _personalTasks;
  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _personalTasks.where((task) {
      if (task.dueDate == null) return true;
      return task.dueDate!.year == today.year &&
             task.dueDate!.month == today.month &&
             task.dueDate!.day == today.day;
    }).toList();
  }

  double get todayProgress {
    final today = todayTasks;
    if (today.isEmpty) return 0.0;
    final completed = today.where((task) => task.isCompleted).length;
    return completed / today.length;
  }

  TasksProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadTasks();
        loadChallenges();
      } else {
        _personalTasks.clear();
        _challenges.clear();
        notifyListeners();
      }
    });
  }

  Future<void> loadTasks() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      _personalTasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChallenges() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('participantIds', arrayContains: _auth.currentUser!.uid)
          .get();

      _challenges = snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    } catch (e) {
      _error = 'Failed to load challenges: $e';
      notifyListeners();
    }
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
    String? challengeId,
    int points = 10,
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final task = Task(
        id: '',
        title: title,
        description: description,
        priority: priority,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        challengeId: challengeId,
        points: points,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('tasks')
          .add(task.toFirestore());

      await loadTasks();
      return true;
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    if (_auth.currentUser == null) return false;

    try {
      final taskIndex = _personalTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return false;

      final task = _personalTasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .update(updatedTask.toFirestore());

      // Update challenge score if applicable
      if (updatedTask.challengeId != null && updatedTask.isCompleted) {
        await _updateChallengeScore(updatedTask.challengeId!, updatedTask.points);
      }

      _personalTasks[taskIndex] = updatedTask;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();

      _personalTasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<String?> createChallenge({
    required String title,
    required String description,
    required DateTime endDate,
  }) async {
    if (_auth.currentUser == null) return null;

    try {
      final code = _generateChallengeCode();
      final challenge = Challenge(
        id: '',
        title: title,
        description: description,
        code: code,
        adminId: _auth.currentUser!.uid,
        participantIds: [_auth.currentUser!.uid],
        createdAt: DateTime.now(),
        endDate: endDate,
        status: ChallengeStatus.active,
        participantScores: {_auth.currentUser!.uid: 0},
        tasks: [],
      );

      final docRef = await _firestore
          .collection('challenges')
          .add(challenge.toFirestore());

      await loadChallenges();
      return code;
    } catch (e) {
      _error = 'Failed to create challenge: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> joinChallenge(String code) async {
    if (_auth.currentUser == null) return false;

    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _error = 'Challenge not found';
        notifyListeners();
        return false;
      }

      final challengeDoc = snapshot.docs.first;
      final challenge = Challenge.fromFirestore(challengeDoc);

      if (challenge.participantIds.contains(_auth.currentUser!.uid)) {
        _error = 'Already joined this challenge';
        notifyListeners();
        return false;
      }

      await challengeDoc.reference.update({
        'participantIds': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        'participantScores.${_auth.currentUser!.uid}': 0,
      });

      await loadChallenges();
      return true;
    } catch (e) {
      _error = 'Failed to join challenge: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _updateChallengeScore(String challengeId, int points) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('challenges').doc(challengeId).update({
        'participantScores.${_auth.currentUser!.uid}': FieldValue.increment(points),
      });
    } catch (e) {
      // Silently handle score update errors
    }
  }

  String _generateChallengeCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
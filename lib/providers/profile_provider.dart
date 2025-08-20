import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum GoalType { daily, weekly, monthly, custom }

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final String unit; // minutes, tasks, sessions, etc.
  final DateTime createdAt;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    required this.createdAt,
    required this.targetDate,
    this.isCompleted = false,
    this.completedAt,
  });

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: GoalType.values[data['type'] ?? 0],
      targetValue: data['targetValue'] ?? 0,
      currentValue: data['currentValue'] ?? 0,
      unit: data['unit'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': Timestamp.fromDate(targetDate),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);
  
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  Goal copyWith({
    String? title,
    String? description,
    GoalType? type,
    int? targetValue,
    int? currentValue,
    String? unit,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      createdAt: createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏆',
      points: data['points'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null 
          ? (data['unlockedAt'] as Timestamp).toDate() 
          : null,
      progress: data['progress'] ?? 0,
      target: data['target'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'progress': progress,
      'target': target,
    };
  }

  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
}

class UserStats {
  final int totalFocusTime; // in minutes
  final int totalTasks;
  final int completedTasks;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalPoints;
  final int goalsCompleted;
  final Map<String, int> categoryStats;
  final DateTime lastActive;

  UserStats({
    this.totalFocusTime = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalPoints = 0,
    this.goalsCompleted = 0,
    this.categoryStats = const {},
    required this.lastActive,
  });

  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    return UserStats(
      totalFocusTime: data['totalFocusTime'] ?? 0,
      totalTasks: data['totalTasks'] ?? 0,
      completedTasks: data['completedTasks'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalSessions: data['totalSessions'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      goalsCompleted: data['goalsCompleted'] ?? 0,
      categoryStats: Map<String, int>.from(data['categoryStats'] ?? {}),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalFocusTime': totalFocusTime,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      'totalPoints': totalPoints,
      'goalsCompleted': goalsCompleted,
      'categoryStats': categoryStats,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  double get taskCompletionRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  
  String get formattedFocusTime {
    final hours = totalFocusTime ~/ 60;
    final minutes = totalFocusTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Goal> _goals = [];
  List<Achievement> _achievements = [];
  UserStats _stats = UserStats(lastActive: DateTime.now());
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  List<Achievement> get achievements => _achievements;
  UserStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Goal> get activeGoals => _goals.where((goal) => !goal.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList();
  List<Achievement> get unlockedAchievements => _achievements.where((achievement) => achievement.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _achievements.where((achievement) => !achievement.isUnlocked).toList();

  ProfileProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadProfile();
      } else {
        _goals.clear();
        _achievements.clear();
        _stats = UserStats(lastActive: DateTime.now());
        notifyListeners();
      }
    });
  }

  Future<void> loadProfile() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Load goals
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .get();

      _goals = goalsSnapshot.docs.map((doc) => Goal.fromFirestore(doc)).toList();

      // Load achievements
      final achievementsSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('achievements')
          .get();

      _achievements = achievementsSnapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList();

      // If no achievements exist, create default ones
      if (_achievements.isEmpty) {
        await _createDefaultAchievements();
      }

      // Load stats
      final statsDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (statsDoc.exists) {
        _stats = UserStats.fromFirestore(statsDoc.data() as Map<String, dynamic>);
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGoal({
    required String title,
    required String description,
    required GoalType type,
    required int targetValue,
    required String unit,
    required DateTime targetDate,
  }) async {
    if (_auth.currentUser == null) return false;

    try {
      final goal = Goal(
        id: '',
        title: title,
        description: description,
        type: type,
        targetValue: targetValue,
        unit: unit,
        createdAt: DateTime.now(),
        targetDate: targetDate,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .add(goal.toFirestore());

      await loadProfile();
      return true;
    } catch (e) {
      _error = 'Failed to add goal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoalProgress(String goalId, int newProgress) async {
    if (_auth.currentUser == null) return false;

    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      final isNowCompleted = newProgress >= goal.targetValue && !goal.isCompleted;
      
      final updatedGoal = goal.copyWith(
        currentValue: newProgress,
        isCompleted: newProgress >= goal.targetValue,
        completedAt: isNowCompleted ? DateTime.now() : goal.completedAt,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .doc(goalId)
          .update(updatedGoal.toFirestore());

      _goals[goalIndex] = updatedGoal;
      
      // Update stats if goal was completed
      if (isNowCompleted) {
        await _updateStats(goalsCompleted: _stats.goalsCompleted + 1);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update goal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .doc(goalId)
          .delete();

      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete goal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStats({
    int? focusTimeIncrement,
    int? tasksIncrement,
    int? completedTasksIncrement,
    int? sessionsIncrement,
    int? pointsIncrement,
    int? goalsCompleted,
    Map<String, int>? categoryStats,
  }) async {
    if (_auth.currentUser == null) return;

    try {
      final newStats = UserStats(
        totalFocusTime: _stats.totalFocusTime + (focusTimeIncrement ?? 0),
        totalTasks: _stats.totalTasks + (tasksIncrement ?? 0),
        completedTasks: _stats.completedTasks + (completedTasksIncrement ?? 0),
        currentStreak: _calculateCurrentStreak(),
        longestStreak: _stats.longestStreak,
        totalSessions: _stats.totalSessions + (sessionsIncrement ?? 0),
        totalPoints: _stats.totalPoints + (pointsIncrement ?? 0),
        goalsCompleted: goalsCompleted ?? _stats.goalsCompleted,
        categoryStats: categoryStats ?? _stats.categoryStats,
        lastActive: DateTime.now(),
      );

      // Update longest streak if current streak is longer
      final updatedStats = UserStats(
        totalFocusTime: newStats.totalFocusTime,
        totalTasks: newStats.totalTasks,
        completedTasks: newStats.completedTasks,
        currentStreak: newStats.currentStreak,
        longestStreak: newStats.currentStreak > _stats.longestStreak 
            ? newStats.currentStreak 
            : _stats.longestStreak,
        totalSessions: newStats.totalSessions,
        totalPoints: newStats.totalPoints,
        goalsCompleted: newStats.goalsCompleted,
        categoryStats: newStats.categoryStats,
        lastActive: newStats.lastActive,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set(updatedStats.toFirestore(), SetOptions(merge: true));

      _stats = updatedStats;
      
      // Check for achievement unlocks
      await _checkAchievements();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update stats: $e';
      notifyListeners();
    }
  }

  Future<void> _updateStats({
    int? focusTimeIncrement,
    int? tasksIncrement,
    int? completedTasksIncrement,
    int? sessionsIncrement,
    int? pointsIncrement,
    int? goalsCompleted,
  }) async {
    await updateStats(
      focusTimeIncrement: focusTimeIncrement,
      tasksIncrement: tasksIncrement,
      completedTasksIncrement: completedTasksIncrement,
      sessionsIncrement: sessionsIncrement,
      pointsIncrement: pointsIncrement,
      goalsCompleted: goalsCompleted,
    );
  }

  int _calculateCurrentStreak() {
    // This is a simplified streak calculation
    // In a real app, you'd track daily activity more precisely
    final now = DateTime.now();
    final lastActive = _stats.lastActive;
    final daysDifference = now.difference(lastActive).inDays;
    
    if (daysDifference <= 1) {
      return _stats.currentStreak + (daysDifference == 1 ? 1 : 0);
    } else {
      return 0; // Streak broken
    }
  }

  Future<void> _createDefaultAchievements() async {
    if (_auth.currentUser == null) return;

    final defaultAchievements = [
      Achievement(id: '', title: 'First Step', description: 'Complete your first task', icon: '👶', points: 10, target: 1),
      Achievement(id: '', title: 'Getting Started', description: 'Complete 10 tasks', icon: '🚀', points: 50, target: 10),
      Achievement(id: '', title: 'Task Master', description: 'Complete 100 tasks', icon: '💪', points: 200, target: 100),
      Achievement(id: '', title: 'Focus Beginner', description: '1 hour of focus time', icon: '⏰', points: 25, target: 60),
      Achievement(id: '', title: 'Focus Pro', description: '10 hours of focus time', icon: '🎯', points: 100, target: 600),
      Achievement(id: '', title: 'Focus Master', description: '100 hours of focus time', icon: '🧠', points: 500, target: 6000),
      Achievement(id: '', title: 'Consistency', description: '7-day streak', icon: '🔥', points: 75, target: 7),
      Achievement(id: '', title: 'Dedication', description: '30-day streak', icon: '💎', points: 300, target: 30),
      Achievement(id: '', title: 'Goal Setter', description: 'Set your first goal', icon: '🎯', points: 20, target: 1),
      Achievement(id: '', title: 'Goal Achiever', description: 'Complete 5 goals', icon: '🏆', points: 150, target: 5),
    ];

    final batch = _firestore.batch();
    for (final achievement in defaultAchievements) {
      final docRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('achievements')
          .doc();
      batch.set(docRef, achievement.toFirestore());
    }
    await batch.commit();
  }

  Future<void> _checkAchievements() async {
    if (_auth.currentUser == null) return;

    bool hasUpdates = false;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      int currentProgress = 0;

      // Calculate progress based on achievement type
      if (achievement.title.contains('task') || achievement.title.contains('Task')) {
        currentProgress = _stats.completedTasks;
      } else if (achievement.title.contains('focus') || achievement.title.contains('Focus')) {
        currentProgress = _stats.totalFocusTime;
      } else if (achievement.title.contains('streak') || achievement.title.contains('Consistency') || achievement.title.contains('Dedication')) {
        currentProgress = _stats.currentStreak;
      } else if (achievement.title.contains('goal') || achievement.title.contains('Goal')) {
        currentProgress = _stats.goalsCompleted;
      }

      // Check if achievement should be unlocked
      if (currentProgress >= achievement.target && !achievement.isUnlocked) {
        final updatedAchievement = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          points: achievement.points,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: currentProgress,
          target: achievement.target,
        );

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('achievements')
            .doc(achievement.id)
            .update(updatedAchievement.toFirestore());

        _achievements[i] = updatedAchievement;
        hasUpdates = true;

        // Add points to total
        await _updateStats(pointsIncrement: achievement.points);
      } else if (currentProgress != achievement.progress) {
        // Update progress
        final updatedAchievement = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          points: achievement.points,
          isUnlocked: achievement.isUnlocked,
          unlockedAt: achievement.unlockedAt,
          progress: currentProgress,
          target: achievement.target,
        );

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('achievements')
            .doc(achievement.id)
            .update({'progress': currentProgress});

        _achievements[i] = updatedAchievement;
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
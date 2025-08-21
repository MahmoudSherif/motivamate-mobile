import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Tab Bar
          GlassContainer(
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'My Tasks'),
                Tab(text: 'Challenges'),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyTasksTab(),
                _buildChallengesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTasksTab() {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, _) {
        final todayTasks = tasksProvider.todayTasks;
        final allTasks = tasksProvider.personalTasks;
        final todayProgress = tasksProvider.todayProgress;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Today's Progress
              GlassContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(todayProgress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(
                      value: todayProgress,
                      backgroundColor: AppColors.glassBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${todayTasks.where((t) => t.isCompleted).length} of ${todayTasks.length} tasks completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Add Task Button
              GlassContainer(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTaskDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Today's Tasks
              if (todayTasks.isNotEmpty) ...[
                _buildSectionHeader('Today\'s Tasks', Icons.today),
                const SizedBox(height: AppSpacing.md),
                ...todayTasks.map((task) => _buildTaskCard(task, tasksProvider)),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              // All Tasks
              if (allTasks.length > todayTasks.length) ...[
                _buildSectionHeader('All Tasks', Icons.list),
                const SizedBox(height: AppSpacing.md),
                ...allTasks
                    .where((task) => !todayTasks.contains(task))
                    .map((task) => _buildTaskCard(task, tasksProvider)),
              ],
              
              // Empty State
              if (allTasks.isEmpty)
                GlassContainer(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.task_alt,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Tasks Yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Add your first task to get started!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesTab() {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, _) {
        final challenges = tasksProvider.challenges;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Challenge Actions
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCreateChallengeDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Challenge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassContainer(
                      child: ElevatedButton.icon(
                        onPressed: () => _showJoinChallengeDialog(context),
                        icon: const Icon(Icons.login),
                        label: const Text('Join Challenge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Active Challenges
              if (challenges.isNotEmpty) ...[
                _buildSectionHeader('My Challenges', Icons.emoji_events),
                const SizedBox(height: AppSpacing.md),
                ...challenges.map((challenge) => _buildChallengeCard(challenge)),
              ] else ...[
                // Empty State
                GlassContainer(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Challenges Yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Create or join a challenge to compete with friends!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task, TasksProvider tasksProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                tasksProvider.toggleTaskCompletion(task.id);
              },
              activeColor: AppColors.primary,
              checkColor: Colors.white,
            ),
            
            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: task.isCompleted 
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      // Priority Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: Text(
                          _getPriorityLabel(task.priority),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Due Date
                      if (task.dueDate != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.dueDate!),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      // Points
                      if (task.challengeId != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${task.points}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.glassPrimary,
                    title: const Text(
                      'Delete Task',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this task?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          tasksProvider.deleteTask(task.id);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Code: ${challenge.code}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getChallengeStatusColor(challenge.status),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    _getChallengeStatusLabel(challenge.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Description
            if (challenge.description.isNotEmpty) ...[
              Text(
                challenge.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Leaderboard Preview
            Text(
              'Leaderboard',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...challenge.participantScores.entries
                .toList()
                ..sort((a, b) => b.value.compareTo(a.value))
                .take(3)
                .map((entry) => _buildLeaderboardItem(entry.key, entry.value)),
            
            const SizedBox(height: AppSpacing.md),
            
            // Challenge Info
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${challenge.participantIds.length} participants',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Ends ${_formatDate(challenge.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(String participantId, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participantId.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'User ${participantId.substring(0, 8)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$score pts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassPrimary,
          title: const Text(
            'Add New Task',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'What do you need to do?',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                  ),
                  dropdownColor: AppColors.glassPrimary,
                  items: TaskPriority.values
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(
                              _getPriorityLabel(priority),
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  title: Text(
                    selectedDate != null
                        ? 'Due: ${_formatDate(selectedDate!)}'
                        : 'Set Due Date (Optional)',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
                  await tasksProvider.addTask(
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    dueDate: selectedDate,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedEndDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassPrimary,
          title: const Text(
            'Create Challenge',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Challenge Title',
                    hintText: 'e.g., Study Marathon',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this challenge about?',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  title: Text(
                    'Ends: ${_formatDate(selectedEndDate)}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedEndDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
                  final code = await tasksProvider.createChallenge(
                    title: titleController.text,
                    description: descriptionController.text,
                    endDate: selectedEndDate,
                  );
                  Navigator.of(context).pop();
                  
                  if (code != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Challenge created! Code: $code'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinChallengeDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: const Text(
          'Join Challenge',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Challenge Code',
            hintText: 'Enter the 6-digit code',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.length == 6) {
                final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
                final success = await tasksProvider.joinChallenge(codeController.text.toUpperCase());
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Joined challenge successfully!' : 'Failed to join challenge'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color _getChallengeStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return AppColors.success;
      case ChallengeStatus.completed:
        return AppColors.primary;
      case ChallengeStatus.expired:
        return AppColors.error;
    }
  }

  String _getChallengeStatusLabel(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.expired:
        return 'Expired';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}
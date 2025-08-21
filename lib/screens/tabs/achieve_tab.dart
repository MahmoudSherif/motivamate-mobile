import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class AchieveTab extends StatefulWidget {
  const AchieveTab({super.key});

  @override
  State<AchieveTab> createState() => _AchieveTabState();
}

class _AchieveTabState extends State<AchieveTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CountDownController _timerController = CountDownController();
  
  int _selectedDuration = 25; // Default 25 minutes
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;

  final List<int> _timerDurations = [15, 25, 45, 60]; // Minutes

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
                Tab(text: 'Focus Timer'),
                Tab(text: 'Goals'),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFocusTimerTab(),
                _buildGoalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTimerTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Timer Display
          GlassContainer(
            child: Column(
              children: [
                Text(
                  'Focus Session',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Circular Timer
                Container(
                  width: 250,
                  height: 250,
                  child: CircularCountDownTimer(
                    duration: _selectedDuration * 60,
                    initialDuration: 0,
                    controller: _timerController,
                    width: 250,
                    height: 250,
                    ringColor: AppColors.glassBorder,
                    fillColor: AppColors.primary,
                    backgroundColor: AppColors.glassPrimary,
                    strokeWidth: 8.0,
                    strokeCap: StrokeCap.round,
                    textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true,
                    isReverseAnimation: true,
                    autoStart: false,
                    onStart: () {
                      setState(() {
                        _isTimerRunning = true;
                        _isTimerPaused = false;
                      });
                    },
                    onComplete: () {
                      setState(() {
                        _isTimerRunning = false;
                        _isTimerPaused = false;
                      });
                      _onTimerComplete();
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Duration Selection
                if (!_isTimerRunning)
                  Column(
                    children: [
                      Text(
                        'Select Duration',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _timerDurations.map((duration) {
                          final isSelected = duration == _selectedDuration;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDuration = duration;
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary
                                    : AppColors.glassPrimary,
                                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary
                                      : AppColors.glassBorder,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$duration',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: isSelected 
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'min',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.8)
                                          : AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Timer Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isTimerRunning) ...[
                      // Pause/Resume Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_isTimerPaused) {
                            _timerController.resume();
                          } else {
                            _timerController.pause();
                          }
                          setState(() {
                            _isTimerPaused = !_isTimerPaused;
                          });
                        },
                        icon: Icon(_isTimerPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isTimerPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                      ),
                      
                      // Stop Button
                      ElevatedButton.icon(
                        onPressed: () {
                          _timerController.reset();
                          setState(() {
                            _isTimerRunning = false;
                            _isTimerPaused = false;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                      ),
                    ] else ...[
                      // Start Button
                      ElevatedButton.icon(
                        onPressed: () {
                          _timerController.start();
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Focus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Focus Tips
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Focus Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ..._focusTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final activeGoals = profileProvider.activeGoals;
        final completedGoals = profileProvider.completedGoals;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Add Goal Button
              GlassContainer(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddGoalDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Set New Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Active Goals
              if (activeGoals.isNotEmpty) ...[
                _buildSectionHeader('Active Goals', Icons.target),
                const SizedBox(height: AppSpacing.md),
                ...activeGoals.map((goal) => _buildGoalCard(goal)),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              // Completed Goals
              if (completedGoals.isNotEmpty) ...[
                _buildSectionHeader('Completed Goals', Icons.check_circle),
                const SizedBox(height: AppSpacing.md),
                ...completedGoals.map((goal) => _buildGoalCard(goal)),
              ],
              
              // Empty State
              if (activeGoals.isEmpty && completedGoals.isEmpty)
                GlassContainer(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.target,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Goals Yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Set your first goal to start tracking your progress!',
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

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  )
                else if (goal.isOverdue)
                  const Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 24,
                  ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: AppColors.glassBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted 
                        ? AppColors.success
                        : goal.isOverdue
                            ? AppColors.warning
                            : AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Goal Info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  goal.isCompleted
                      ? 'Completed'
                      : goal.isOverdue
                          ? 'Overdue'
                          : '${goal.daysRemaining} days left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: goal.isCompleted
                        ? AppColors.success
                        : goal.isOverdue
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (!goal.isCompleted)
                  TextButton(
                    onPressed: () => _showUpdateGoalDialog(context, goal),
                    child: const Text('Update'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onTimerComplete() {
    // Update stats
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.updateStats(
      focusTimeIncrement: _selectedDuration,
      sessionsIncrement: 1,
      pointsIncrement: _selectedDuration, // 1 point per minute
    );

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: const Text(
          '🎉 Session Complete!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Great job! You completed a ${_selectedDuration}-minute focus session.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();
    GoalType selectedType = GoalType.daily;
    String selectedUnit = 'minutes';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassPrimary,
          title: const Text(
            'Set New Goal',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g., Study for 2 hours daily',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DropdownButton<String>(
                      value: selectedUnit,
                      dropdownColor: AppColors.glassPrimary,
                      items: ['minutes', 'hours', 'tasks', 'sessions']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                    ),
                  ],
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
                if (titleController.text.isNotEmpty && targetController.text.isNotEmpty) {
                  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                  await profileProvider.addGoal(
                    title: titleController.text,
                    description: descriptionController.text,
                    type: selectedType,
                    targetValue: int.parse(targetController.text),
                    unit: selectedUnit,
                    targetDate: selectedDate,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateGoalDialog(BuildContext context, Goal goal) {
    final progressController = TextEditingController(
      text: goal.currentValue.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: Text(
          'Update Progress',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: progressController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Progress',
                suffixText: goal.unit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newProgress = int.tryParse(progressController.text) ?? goal.currentValue;
              final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
              await profileProvider.updateGoalProgress(goal.id, newProgress);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  final List<String> _focusTips = [
    'Find a quiet, comfortable space free from distractions',
    'Turn off notifications on your devices',
    'Keep water and healthy snacks nearby',
    'Take deep breaths before starting your session',
    'Set a clear intention for what you want to accomplish',
    'Use background music or white noise if it helps',
    'Take short breaks every 25-30 minutes',
  ];
}
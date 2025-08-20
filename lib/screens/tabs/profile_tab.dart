import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, AuthProvider>(
      builder: (context, profileProvider, authProvider, _) {
        final user = authProvider.user;
        final stats = profileProvider.stats;
        
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Profile Header
              GlassContainer(
                child: Column(
                  children: [
                    // User Info
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName?.isNotEmpty == true 
                                  ? user!.displayName!.substring(0, 1)
                                  : user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppSpacing.md),
                        
                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName?.isNotEmpty == true 
                                    ? user!.displayName!
                                    : 'User',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                user?.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stats.totalPoints} points',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Sign Out Button
                        IconButton(
                          onPressed: () => _showSignOutDialog(context, authProvider),
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Focus Time',
                            stats.formattedFocusTime,
                            Icons.timer,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Tasks Done',
                            '${stats.completedTasks}',
                            Icons.task_alt,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Streak',
                            '${stats.currentStreak}',
                            Icons.local_fire_department,
                            AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
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
                    Tab(text: 'Stats'),
                    Tab(text: 'Achievements'),
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
                    _buildStatsTab(stats),
                    _buildAchievementsTab(profileProvider),
                    _buildGoalsTab(profileProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(UserStats stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Detailed Stats
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                _buildDetailedStatRow('Total Focus Sessions', '${stats.totalSessions}', Icons.play_circle),
                _buildDetailedStatRow('Total Tasks Created', '${stats.totalTasks}', Icons.add_task),
                _buildDetailedStatRow('Task Completion Rate', '${(stats.taskCompletionRate * 100).toInt()}%', Icons.trending_up),
                _buildDetailedStatRow('Longest Streak', '${stats.longestStreak} days', Icons.emoji_events),
                _buildDetailedStatRow('Goals Completed', '${stats.goalsCompleted}', Icons.flag),
                _buildDetailedStatRow('Total Points Earned', '${stats.totalPoints}', Icons.star),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Progress Chart
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.glassBorder,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const style = TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              Widget text;
                              switch (value.toInt()) {
                                case 0:
                                  text = const Text('Mon', style: style);
                                  break;
                                case 1:
                                  text = const Text('Tue', style: style);
                                  break;
                                case 2:
                                  text = const Text('Wed', style: style);
                                  break;
                                case 3:
                                  text = const Text('Thu', style: style);
                                  break;
                                case 4:
                                  text = const Text('Fri', style: style);
                                  break;
                                case 5:
                                  text = const Text('Sat', style: style);
                                  break;
                                case 6:
                                  text = const Text('Sun', style: style);
                                  break;
                                default:
                                  text = const Text('', style: style);
                                  break;
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: text,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateWeeklyData(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.accent,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.primary.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(ProfileProvider profileProvider) {
    final unlockedAchievements = profileProvider.unlockedAchievements;
    final lockedAchievements = profileProvider.lockedAchievements;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress Summary
          GlassContainer(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Unlocked',
                    '${unlockedAchievements.length}',
                    Icons.emoji_events,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'In Progress',
                    '${lockedAchievements.length}',
                    Icons.pending,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Total Points',
                    '${profileProvider.stats.totalPoints}',
                    Icons.star,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Unlocked Achievements
          if (unlockedAchievements.isNotEmpty) ...[
            _buildSectionHeader('Unlocked Achievements', Icons.emoji_events),
            const SizedBox(height: AppSpacing.md),
            ...unlockedAchievements.map((achievement) => _buildAchievementCard(achievement, true)),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          // Locked Achievements
          if (lockedAchievements.isNotEmpty) ...[
            _buildSectionHeader('In Progress', Icons.pending),
            const SizedBox(height: AppSpacing.md),
            ...lockedAchievements.map((achievement) => _buildAchievementCard(achievement, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsTab(ProfileProvider profileProvider) {
    final activeGoals = profileProvider.activeGoals;
    final completedGoals = profileProvider.completedGoals;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Goals Summary
          GlassContainer(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    '${activeGoals.length}',
                    Icons.flag,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${completedGoals.length}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '${completedGoals.isEmpty ? 0 : ((completedGoals.length / (activeGoals.length + completedGoals.length)) * 100).toInt()}%',
                    Icons.trending_up,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Active Goals
          if (activeGoals.isNotEmpty) ...[
            _buildSectionHeader('Active Goals', Icons.flag),
            const SizedBox(height: AppSpacing.md),
            ...activeGoals.map((goal) => _buildGoalCard(goal)),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          // Completed Goals
          if (completedGoals.isNotEmpty) ...[
            _buildSectionHeader('Completed Goals', Icons.check_circle),
            const SizedBox(height: AppSpacing.md),
            ...completedGoals.take(5).map((goal) => _buildGoalCard(goal)),
          ],
          
          // Empty State
          if (activeGoals.isEmpty && completedGoals.isEmpty)
            GlassContainer(
              child: Column(
                children: [
                  const Icon(
                    Icons.flag,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No Goals Set',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Go to the Achieve tab to set your first goal!',
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

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        opacity: isUnlocked ? 0.2 : 0.1,
        child: Row(
          children: [
            // Achievement Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.accent.withOpacity(0.2) : AppColors.glassPrimary,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isUnlocked ? AppColors.accent : AppColors.glassBorder,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Achievement Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Progress Bar
                  if (!isUnlocked) ...[
                    LinearProgressIndicator(
                      value: achievement.progressPercentage,
                      backgroundColor: AppColors.glassBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${achievement.progress}/${achievement.target}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Points
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: isUnlocked ? AppColors.accent : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.points}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUnlocked ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(achievement.unlockedAt!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (goal.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  )
                else if (goal.isOverdue)
                  const Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 20,
                  ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Progress
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
            
            const SizedBox(height: AppSpacing.sm),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentValue}/${goal.targetValue} ${goal.unit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  goal.isCompleted
                      ? 'Completed!'
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateWeeklyData() {
    // Generate sample weekly progress data
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 1),
      const FlSpot(2, 4),
      const FlSpot(3, 2),
      const FlSpot(4, 5),
      const FlSpot(5, 3),
      const FlSpot(6, 4),
    ];
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
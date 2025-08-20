import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quotes_provider.dart';
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/achieve_tab.dart';
import 'tabs/inspiration_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    const AchieveTab(),
    const TasksTab(),
    const CalendarTab(),
    const NotesTab(),
    const ProfileTab(),
    const InspirationTab(),
  ];
  
  final List<String> _tabTitles = [
    'Achieve',
    'Tasks',
    'Calendar',
    'Notes',
    'Profile',
    'Inspire',
  ];
  
  final List<IconData> _tabIcons = [
    Icons.target,
    Icons.check_box,
    Icons.calendar_today,
    Icons.sticky_note_2,
    Icons.person,
    Icons.lightbulb,
  ];

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _tabTitles[_currentIndex],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Main content
            Expanded(
              child: _tabs[_currentIndex],
            ),
            
            // Quotes bar
            _buildQuotesBar(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassPrimary,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: List.generate(_tabIcons.length, (index) {
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == index 
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_tabIcons[index]),
            ),
            label: _tabTitles[index],
          );
        }),
      ),
    );
  }

  Widget _buildQuotesBar() {
    return Consumer<QuotesProvider>(
      builder: (context, quotesProvider, _) {
        final quote = quotesProvider.currentQuote;
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          child: Container(
            key: ValueKey(quote.text),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quote.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: quote.isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 2),
                Text(
                  '— ${quote.author}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: quote.isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
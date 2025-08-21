import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/calendar_provider.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Calendar Widget
                GlassContainer(
                  child: TableCalendar<CalendarEvent>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: calendarProvider.focusedDate,
                    selectedDayPredicate: (day) {
                      return isSameDay(calendarProvider.selectedDate, day);
                    },
                    calendarFormat: _calendarFormat,
                    eventLoader: calendarProvider.getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                      holidayTextStyle: const TextStyle(color: AppColors.accent),
                      defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                      todayTextStyle: const TextStyle(color: Colors.white),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ) ?? const TextStyle(),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimary,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: const TextStyle(color: AppColors.textSecondary),
                      weekendStyle: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      calendarProvider.setSelectedDate(selectedDay);
                      calendarProvider.setFocusedDate(focusedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      calendarProvider.setFocusedDate(focusedDay);
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Add Event Button
                GlassContainer(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEventDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Selected Day Events
                if (calendarProvider.selectedDateEvents.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Events for ${_formatSelectedDate(calendarProvider.selectedDate)}',
                    Icons.event,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...calendarProvider.selectedDateEvents.map((event) => _buildEventCard(event, calendarProvider)),
                ] else ...[
                  GlassContainer(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No events for ${_formatSelectedDate(calendarProvider.selectedDate)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap "Add Event" to create your first event!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: AppSpacing.lg),
                
                // Upcoming Events
                if (calendarProvider.upcomingEvents.isNotEmpty) ...[
                  _buildSectionHeader('Upcoming Events', Icons.upcoming),
                  const SizedBox(height: AppSpacing.md),
                  ...calendarProvider.upcomingEvents.take(5).map((event) => _buildEventCard(event, calendarProvider)),
                ],
              ],
            ),
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

  Widget _buildEventCard(CalendarEvent event, CalendarProvider calendarProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        child: Row(
          children: [
            // Event Color Indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Event Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CalendarProvider.getIconForEventType(event.type),
                        size: 16,
                        color: event.color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        event.isAllDay
                            ? 'All Day'
                            : '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Location
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Description
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppColors.primary,
                  onPressed: () => _showEditEventDialog(context, event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: AppColors.error,
                  onPressed: () => _showDeleteEventDialog(context, event, calendarProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    _showEventDialog(context, null);
  }

  void _showEditEventDialog(BuildContext context, CalendarEvent event) {
    _showEventDialog(context, event);
  }

  void _showEventDialog(BuildContext context, CalendarEvent? event) {
    final isEditing = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    
    EventType selectedType = event?.type ?? EventType.study;
    Color selectedColor = event?.color ?? CalendarProvider.eventColors[0];
    DateTime selectedStartDate = event?.startTime ?? Provider.of<CalendarProvider>(context, listen: false).selectedDate;
    TimeOfDay selectedStartTime = event != null 
        ? TimeOfDay.fromDateTime(event.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    DateTime selectedEndDate = event?.endTime ?? selectedStartDate;
    TimeOfDay selectedEndTime = event != null
        ? TimeOfDay.fromDateTime(event.endTime)
        : const TimeOfDay(hour: 10, minute: 0);
    bool isAllDay = event?.isAllDay ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassPrimary,
          title: Text(
            isEditing ? 'Edit Event' : 'Add Event',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'What is this event about?',
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
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<EventType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                  ),
                  dropdownColor: AppColors.glassPrimary,
                  items: EventType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  CalendarProvider.getIconForEventType(type),
                                  size: 16,
                                  color: CalendarProvider.getColorForEventType(type),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  type.name.toUpperCase(),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      selectedColor = CalendarProvider.getColorForEventType(value);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Color Selection
                Text(
                  'Event Color',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: CalendarProvider.eventColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // All Day Toggle
                Row(
                  children: [
                    Checkbox(
                      value: isAllDay,
                      onChanged: (value) {
                        setState(() {
                          isAllDay = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const Text(
                      'All Day',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                
                // Date and Time Selection
                if (!isAllDay) ...[
                  ListTile(
                    title: Text(
                      'Start: ${_formatDateTime(selectedStartDate, selectedStartTime)}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: const Icon(Icons.schedule, color: AppColors.primary),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedStartTime,
                        );
                        if (time != null) {
                          setState(() {
                            selectedStartDate = date;
                            selectedStartTime = time;
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'End: ${_formatDateTime(selectedEndDate, selectedEndTime)}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: const Icon(Icons.schedule, color: AppColors.primary),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate,
                        firstDate: selectedStartDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedEndTime,
                        );
                        if (time != null) {
                          setState(() {
                            selectedEndDate = date;
                            selectedEndTime = time;
                          });
                        }
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    title: Text(
                      'Date: ${_formatDate(selectedStartDate)}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedStartDate = date;
                          selectedEndDate = date;
                        });
                      }
                    },
                  ),
                ],
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
                  final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                  
                  final startDateTime = isAllDay
                      ? DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day)
                      : DateTime(
                          selectedStartDate.year,
                          selectedStartDate.month,
                          selectedStartDate.day,
                          selectedStartTime.hour,
                          selectedStartTime.minute,
                        );
                  
                  final endDateTime = isAllDay
                      ? DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day, 23, 59)
                      : DateTime(
                          selectedEndDate.year,
                          selectedEndDate.month,
                          selectedEndDate.day,
                          selectedEndTime.hour,
                          selectedEndTime.minute,
                        );
                  
                  bool success;
                  if (isEditing) {
                    success = await calendarProvider.updateEvent(
                      event!.id,
                      title: titleController.text,
                      description: descriptionController.text,
                      startTime: startDateTime,
                      endTime: endDateTime,
                      type: selectedType,
                      color: selectedColor,
                      isAllDay: isAllDay,
                      location: locationController.text.isEmpty ? null : locationController.text,
                    );
                  } else {
                    success = await calendarProvider.addEvent(
                      title: titleController.text,
                      description: descriptionController.text,
                      startTime: startDateTime,
                      endTime: endDateTime,
                      type: selectedType,
                      color: selectedColor,
                      isAllDay: isAllDay,
                      location: locationController.text.isEmpty ? null : locationController.text,
                    );
                  }
                  
                  Navigator.of(context).pop();
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Event updated successfully!' : 'Event added successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEventDialog(BuildContext context, CalendarEvent event, CalendarProvider calendarProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: const Text(
          'Delete Event',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await calendarProvider.deleteEvent(event.id);
              Navigator.of(context).pop();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    return '${_formatDate(date)} ${time.format(context)}';
  }
}
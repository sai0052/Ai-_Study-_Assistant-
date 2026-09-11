import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Wraps table_calendar with app theming — used at the top of the Study
/// Planner screen so students can see which days have sessions scheduled.
class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, int> sessionCountByDay;
  final ValueChanged<DateTime> onDaySelected;

  const ScheduleCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.sessionCountByDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 90)),
        lastDay: DateTime.now().add(const Duration(days: 180)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) => onDaySelected(selected),
        calendarFormat: CalendarFormat.week,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.4), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
        ),
        eventLoader: (day) {
          final normalized = DateTime(day.year, day.month, day.day);
          final count = sessionCountByDay[normalized] ?? 0;
          return List.filled(count, 1);
        },
      ),
    );
  }
}

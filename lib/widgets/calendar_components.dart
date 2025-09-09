import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Advanced calendar components for NDIS appointment scheduling
/// Following 2025 design trends with sophisticated interaction patterns

/// Enhanced calendar view with appointment integration
class EnhancedCalendarView extends StatefulWidget {
  final DateTime initialDate;
  final List<CalendarEvent> events;
  final Function(DateTime)? onDateSelected;
  final Function(CalendarEvent)? onEventTap;
  final bool showWeekView;
  final CalendarStyle style;

  const EnhancedCalendarView({
    super.key,
    required this.initialDate,
    this.events = const [],
    this.onDateSelected,
    this.onEventTap,
    this.showWeekView = false,
    this.style = const CalendarStyle(),
  });

  @override
  State<EnhancedCalendarView> createState() => _EnhancedCalendarViewState();
}

class _EnhancedCalendarViewState extends State<EnhancedCalendarView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _transitionController;
  late PageController _pageController;

  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _selectedDate = widget.initialDate;
    _initializeControllers();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageController = PageController(initialPage: 1000);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transitionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animationController,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCalendarHeader(context),
                _buildCalendarBody(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GoogleTheme.googleBlue.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous month',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatMonthYear(_currentDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next month',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
            tooltip: 'Go to today',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody(BuildContext context) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: _isTransitioning ? const Offset(0.1, 0) : Offset.zero,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _transitionController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: _isTransitioning ? 0.7 : 1.0,
              end: 1.0,
            ).animate(_transitionController),
            child: widget.showWeekView
                ? _buildWeekView(context)
                : _buildMonthView(context),
          ),
        );
      },
    );
  }

  Widget _buildMonthView(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        _buildWeekdayHeaders(context),

        // Calendar grid
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: 42, // 6 weeks
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 1;

              if (dayNumber <= 0 || dayNumber > daysInMonth) {
                return const SizedBox(); // Empty cell
              }

              final date =
                  DateTime(_currentDate.year, _currentDate.month, dayNumber);
              return _buildDayCell(context, date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView(BuildContext context) {
    // TODO: Implement week view
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Week view coming soon'),
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Text(
              day,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedDate != null &&
        date.day == _selectedDate!.day &&
        date.month == _selectedDate!.month &&
        date.year == _selectedDate!.year;
    final isToday = _isToday(date);
    final hasEvents = _getEventsForDate(date).isNotEmpty;
    final isCurrentMonth = date.month == _currentDate.month;

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? GoogleTheme.googleBlue
              : isToday
                  ? GoogleTheme.googleBlue.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: GoogleTheme.googleBlue, width: 1)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isCurrentMonth
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getEventsForDate(date).take(3).map((event) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : event.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      return event.startTime.day == date.day &&
          event.startTime.month == date.month &&
          event.startTime.year == date.year;
    }).toList();
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    widget.onDateSelected?.call(date);
    HapticFeedback.lightImpact();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _isTransitioning = true;
    });
    _transitionController.forward().then((_) {
      setState(() => _isTransitioning = false);
      _transitionController.reset();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _isTransitioning = true;
    });
    _transitionController.forward().then((_) {
      setState(() => _isTransitioning = false);
      _transitionController.reset();
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
    widget.onDateSelected?.call(DateTime.now());
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) => _buildMonthYearPickerDialog(),
    );
  }

  Widget _buildMonthYearPickerDialog() {
    return AlertDialog(
      title: const Text('Select Month & Year'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          selectedDate: _currentDate,
          onChanged: (date) {
            setState(() => _currentDate = date);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

/// Appointment card with enhanced styling and interactions
class AppointmentCard extends StatefulWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final bool isCompact;

  const AppointmentCard({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onCancel,
    this.isCompact = false,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeText =
        '${_formatTime(widget.event.startTime)} - ${_formatTime(widget.event.endTime)}';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _handleTapDown(),
            onTapUp: (_) => _handleTapUp(),
            onTapCancel: () => _handleTapUp(),
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: widget.isCompact ? 8 : 12),
              padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.event.color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.event.color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.event.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getEventIcon(widget.event.type),
                          color: widget.event.color,
                          size: widget.isCompact ? 16 : 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!widget.isCompact) ...[
                              const SizedBox(height: 2),
                              Text(
                                timeText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildStatusIndicator(context),
                    ],
                  ),
                  if (!widget.isCompact) ...[
                    const SizedBox(height: 12),
                    if (widget.event.provider != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.provider!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (widget.event.location != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.event.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.onEdit != null || widget.onCancel != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (widget.onEdit != null)
                            Expanded(
                              child: TextButton.icon(
                                onPressed: widget.onEdit,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: GoogleTheme.googleBlue,
                                ),
                              ),
                            ),
                          if (widget.onEdit != null && widget.onCancel != null)
                            const SizedBox(width: 8),
                          if (widget.onCancel != null)
                            Expanded(
                              child: TextButton.icon(
                                onPressed: widget.onCancel,
                                icon: const Icon(Icons.cancel, size: 16),
                                label: const Text('Cancel'),
                                style: TextButton.styleFrom(
                                  foregroundColor: GoogleTheme.googleRed,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.event.status) {
      case AppointmentStatus.confirmed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: GoogleTheme.googleGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Confirmed',
            style: theme.textTheme.labelSmall?.copyWith(
              color: GoogleTheme.googleGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case AppointmentStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: GoogleTheme.googleYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Pending',
            style: theme.textTheme.labelSmall?.copyWith(
              color: GoogleTheme.googleYellow.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case AppointmentStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: GoogleTheme.googleRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Cancelled',
            style: theme.textTheme.labelSmall?.copyWith(
              color: GoogleTheme.googleRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  IconData _getEventIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.therapy:
        return Icons.healing;
      case AppointmentType.assessment:
        return Icons.assignment;
      case AppointmentType.support:
        return Icons.support_agent;
      case AppointmentType.review:
        return Icons.rate_review;
      case AppointmentType.other:
        return Icons.event;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
}

/// Time slot selector for appointment booking
class TimeSlotSelector extends StatefulWidget {
  final DateTime selectedDate;
  final List<TimeSlot> availableSlots;
  final Function(TimeSlot)? onSlotSelected;
  final TimeSlot? selectedSlot;

  const TimeSlotSelector({
    super.key,
    required this.selectedDate,
    required this.availableSlots,
    this.onSlotSelected,
    this.selectedSlot,
  });

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Times',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableSlots.map((slot) {
            final isSelected = widget.selectedSlot == slot;

            return GestureDetector(
              onTap: () {
                widget.onSlotSelected?.call(slot);
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GoogleTheme.googleBlue
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? GoogleTheme.googleBlue
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  slot.displayTime,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color:
                        isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Data models
class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? provider;
  final String? location;
  final String? notes;

  // NDIS-specific properties
  final double? providerRating;
  final double? cost;
  final String? ndisCategory;
  final bool? claimable;
  final bool? transportRequired;
  final String? emergencyContact;
  final String? cancellationPolicy;
  final List<String>? requiredDocuments;
  final String? fundingSource;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.type,
    required this.status,
    this.provider,
    this.location,
    this.notes,
    this.providerRating,
    this.cost,
    this.ndisCategory,
    this.claimable,
    this.transportRequired,
    this.emergencyContact,
    this.cancellationPolicy,
    this.requiredDocuments,
    this.fundingSource,
  });
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String displayTime;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.displayTime,
  });
}

enum AppointmentType { therapy, assessment, support, review, other }

enum AppointmentStatus { confirmed, pending, cancelled }

class CalendarStyle {
  final Color primaryColor;
  final Color selectedColor;
  final Color todayColor;
  final TextStyle? dayTextStyle;
  final TextStyle? selectedDayTextStyle;

  const CalendarStyle({
    this.primaryColor = const Color(0xFF1A73E8),
    this.selectedColor = const Color(0xFF1A73E8),
    this.todayColor = const Color(0xFF1A73E8),
    this.dayTextStyle,
    this.selectedDayTextStyle,
  });
}

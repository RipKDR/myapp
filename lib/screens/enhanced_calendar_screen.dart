import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/calendar_components.dart';
import '../widgets/enhanced_form_components.dart';
import '../widgets/trending_2025_components.dart';
import '../widgets/neo_brutalism_components.dart';
import '../widgets/advanced_glassmorphism_2025.dart';
import '../widgets/cinematic_data_storytelling.dart';

/// Enhanced calendar and appointment scheduling screen
/// Following 2025 design trends with sophisticated booking capabilities
class EnhancedCalendarScreen extends StatefulWidget {
  const EnhancedCalendarScreen({super.key});

  @override
  State<EnhancedCalendarScreen> createState() => _EnhancedCalendarScreenState();
}

class _EnhancedCalendarScreenState extends State<EnhancedCalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _contentController;

  DateTime _selectedDate = DateTime.now();

  // Enhanced appointment data with NDIS-specific features
  final List<CalendarEvent> _appointments = [
    CalendarEvent(
      id: '1',
      title: 'Physiotherapy Session',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 15)),
      color: GoogleTheme.googleBlue,
      type: AppointmentType.therapy,
      status: AppointmentStatus.confirmed,
      provider: 'FlexCare Physiotherapy',
      location: '123 Health Street, Melbourne',
      providerRating: 4.8,
      cost: 89.50,
      ndisCategory: 'Core Support - Assistance with Daily Personal Activities',
      claimable: true,
      transportRequired: false,
      notes: 'Bring comfortable clothes and water bottle',
      emergencyContact: 'Jane Smith: 0412 345 678',
    ),
    CalendarEvent(
      id: '2',
      title: 'OT Assessment',
      startTime: DateTime.now().add(const Duration(days: 3, hours: 10)),
      endTime:
          DateTime.now().add(const Duration(days: 3, hours: 11, minutes: 30)),
      color: GoogleTheme.googleGreen,
      type: AppointmentType.assessment,
      status: AppointmentStatus.pending,
      provider: 'Ability OT Services',
      location: '456 Care Avenue, Melbourne',
      providerRating: 4.9,
      cost: 125.00,
      ndisCategory: 'Capacity Building - Improved Daily Living',
      claimable: true,
      transportRequired: true,
      notes: 'Initial assessment for home modifications',
      emergencyContact: 'Healthcare Team: 1800 NDIS',
    ),
    CalendarEvent(
      id: '3',
      title: 'Support Worker Visit',
      startTime: DateTime.now().add(const Duration(days: 7, hours: 16)),
      endTime: DateTime.now().add(const Duration(days: 7, hours: 18)),
      color: GoogleTheme.ndisTeal,
      type: AppointmentType.support,
      status: AppointmentStatus.confirmed,
      provider: 'CareCo Support Services',
      location: 'Home visit',
      providerRating: 4.7,
      cost: 156.00,
      ndisCategory: 'Core Support - Social and Community Participation',
      claimable: true,
      transportRequired: false,
      notes: 'Community outing - museum visit',
      emergencyContact: 'Support Coordinator: 0423 789 012',
    ),
    CalendarEvent(
      id: '4',
      title: 'Plan Review Meeting',
      startTime: DateTime.now().add(const Duration(days: 14, hours: 11)),
      endTime: DateTime.now().add(const Duration(days: 14, hours: 12)),
      color: GoogleTheme.ndisPurple,
      type: AppointmentType.review,
      status: AppointmentStatus.confirmed,
      provider: 'NDIS Planning Team',
      location: 'NDIS Office - Level 3, 789 Plan Street',
      providerRating: 4.6,
      cost: 0.00,
      ndisCategory: 'Plan Management',
      claimable: false,
      transportRequired: true,
      notes: 'Bring current plan and goal progress reports',
      emergencyContact: 'NDIS Hotline: 1800 800 110',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 2, vsync: this);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context),
          ];
        },
        body: AnimatedBuilder(
          animation: _contentController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _contentController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOutCubic,
                )),
                child: Column(
                  children: [
                    _buildViewToggle(context),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCalendarTab(context),
                          _buildListTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBookingDialog,
        backgroundColor: GoogleTheme.googleBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Book Session'),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final upcomingCount = _appointments
        .where((apt) => apt.startTime.isAfter(DateTime.now()))
        .length;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text('Calendar'),
      actions: [
        Trending2025Components.buildInteractiveButton(
          label: 'Voice',
          onPressed: _activateVoiceCommands,
          icon: Icons.mic,
          isPrimary: false,
          backgroundColor: GoogleTheme.googleBlue,
          hasRippleEffect: true,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showCalendarSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Calendar Settings',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: NeoBrutalismComponents.buildStrikingHeader(
          context: context,
          title: 'Your NDIS Schedule',
          subtitle: 'Manage appointments with confidence',
          backgroundColor: GoogleTheme.googleBlue,
          trailing: CinematicDataStoryTelling.buildAnimatedDataStory(
            context: context,
            title: 'Upcoming Sessions',
            value: upcomingCount.toString(),
            previousValue: (upcomingCount - 1).toString(),
            trendDescription: 'Well organized schedule',
            icon: Icons.event_available,
            color: GoogleTheme.googleGreen,
            showCelebration: upcomingCount > 3,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: GoogleTheme.googleBlue,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: GoogleTheme.googleBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.calendar_month, size: 20),
            text: 'Calendar',
          ),
          Tab(
            icon: Icon(Icons.list, size: 20),
            text: 'List View',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar view
          EnhancedCalendarView(
            initialDate: _selectedDate,
            events: _appointments,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
            onEventTap: _showEventDetails,
          ),

          const SizedBox(height: 24),

          // Selected date appointments
          _buildSelectedDateAppointments(context),
        ],
      ),
    );
  }

  Widget _buildListTab(BuildContext context) {
    final upcomingAppointments = _appointments
        .where((apt) => apt.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildListHeader(context, upcomingAppointments.length);
        }

        final appointment = upcomingAppointments[index - 1];
        return AppointmentCard(
          event: appointment,
          onTap: () => _showEventDetails(appointment),
          onEdit: () => _editAppointment(appointment),
          onCancel: () => _cancelAppointment(appointment),
        );
      },
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GoogleTheme.googleBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GoogleTheme.googleBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: GoogleTheme.googleBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Appointments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: GoogleTheme.googleBlue,
                  ),
                ),
                Text(
                  '$count sessions scheduled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateAppointments(BuildContext context) {
    final theme = Theme.of(context);
    final appointmentsForDate = _appointments
        .where((apt) =>
            apt.startTime.day == _selectedDate.day &&
            apt.startTime.month == _selectedDate.month &&
            apt.startTime.year == _selectedDate.year)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatSelectedDate(_selectedDate),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (appointmentsForDate.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      _showBookingDialog(selectedDate: _selectedDate),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (appointmentsForDate.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments scheduled',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book a session to get started',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  EnhancedButton(
                    onPressed: () =>
                        _showBookingDialog(selectedDate: _selectedDate),
                    child: const Text('Book Session'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...appointmentsForDate.map((appointment) {
              return AppointmentCard(
                event: appointment,
                onTap: () => _showEventDetails(appointment),
                onEdit: () => _editAppointment(appointment),
                onCancel: () => _cancelAppointment(appointment),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  void _showBookingDialog({DateTime? selectedDate}) {
    showDialog(
      context: context,
      builder: (context) => AdvancedGlassmorphism2025.buildGlassModalOverlay(
        context: context,
        child: _buildEnhancedBookingDialog(selectedDate),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEnhancedBookingDialog(DateTime? preSelectedDate) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Neo-brutalism header for booking
          NeoBrutalismComponents.buildStrikingHeader(
            context: context,
            title: 'Book NDIS Session',
            subtitle: 'Schedule your healthcare appointment',
            backgroundColor: GoogleTheme.ndisTeal,
          ),

          const SizedBox(height: 24),

          // Voice booking option
          Trending2025Components.buildVoiceInterface(
            context: context,
            isListening: false,
            onVoiceToggle: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice booking coming soon!')),
              );
            },
            transcribedText: null,
            isAccessible: true,
          ),

          const SizedBox(height: 24),

          // Enhanced service type selection with NDIS categories
          _buildNDISServiceSelection(),

          const SizedBox(height: 24),

          // Enhanced date and time selection
          _buildAdvancedDateTimeSelection(preSelectedDate),

          const SizedBox(height: 24),

          // NDIS-specific booking options
          _buildNDISBookingOptions(),

          const SizedBox(height: 32),

          // Enhanced action buttons
          Row(
            children: [
              Expanded(
                child: Trending2025Components.buildInteractiveButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  isPrimary: false,
                  backgroundColor: GoogleTheme.googleRed,
                  hasRippleEffect: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Trending2025Components.buildInteractiveButton(
                  label: 'Book Session',
                  onPressed: _confirmEnhancedBooking,
                  icon: Icons.event_available,
                  backgroundColor: GoogleTheme.ndisTeal,
                  hasPulseAnimation: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<TimeSlot> _generateTimeSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final baseTime =
        DateTime(date.year, date.month, date.day, 9); // Start at 9 AM

    for (int i = 0; i < 16; i++) {
      // 9 AM to 5 PM (8 hours, 30-min slots)
      final startTime = baseTime.add(Duration(minutes: i * 30));
      final endTime = startTime.add(const Duration(minutes: 30));

      // Check if slot conflicts with existing appointments
      final hasConflict = _appointments.any((apt) =>
          (startTime.isBefore(apt.endTime) && endTime.isAfter(apt.startTime)));

      slots.add(TimeSlot(
        startTime: startTime,
        endTime: endTime,
        isAvailable: !hasConflict,
        displayTime: _formatTimeSlot(startTime),
      ));
    }

    return slots.where((slot) => slot.isAvailable).toList();
  }

  String _formatTimeSlot(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }

  // Event handlers
  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => _buildEventDetailsDialog(event),
    );
  }

  Widget _buildEventDetailsDialog(CalendarEvent event) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: event.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.schedule, 'Time',
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
            if (event.provider != null)
              _buildDetailRow(Icons.business, 'Provider', event.provider!),
            if (event.location != null)
              _buildDetailRow(Icons.location_on, 'Location', event.location!),
            _buildDetailRow(
                Icons.info_outline, 'Status', _getStatusText(event.status)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: EnhancedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editAppointment(event);
                    },
                    isSecondary: true,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EnhancedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelAppointment(event);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
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

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending Confirmation';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // Event handlers
  void _editAppointment(CalendarEvent event) {
    // TODO: Implement edit appointment
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit appointment feature coming soon')),
    );
  }

  void _cancelAppointment(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text('Are you sure you want to cancel "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          EnhancedButton(
            onPressed: () {
              Navigator.pop(context);
              _performCancel(event);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _performCancel(CalendarEvent event) {
    // TODO: Implement actual cancellation
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} has been cancelled'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _selectBookingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      // TODO: Handle date selection
      HapticFeedback.lightImpact();
    }
  }

  void _showCalendarSettings() {
    // TODO: Implement calendar settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calendar settings feature coming soon')),
    );
  }

  void _activateVoiceCommands() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Say "Book appointment" or "Show my schedule"'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildNDISServiceSelection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NDIS Service Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // NDIS service categories with funding info
        Column(
          children: [
            _buildNDISServiceCard(
              'Physiotherapy',
              'Core Support - Assistance with Daily Living',
              Icons.healing,
              GoogleTheme.googleBlue,
              '\$85-120 per session',
              'Fully claimable',
            ),
            const SizedBox(height: 8),
            _buildNDISServiceCard(
              'Occupational Therapy',
              'Capacity Building - Improved Daily Living',
              Icons.accessibility,
              GoogleTheme.googleGreen,
              '\$110-150 per session',
              'Fully claimable',
            ),
            const SizedBox(height: 8),
            _buildNDISServiceCard(
              'Support Worker',
              'Core Support - Social and Community Participation',
              Icons.support_agent,
              GoogleTheme.ndisTeal,
              '\$55-85 per hour',
              'Fully claimable',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNDISServiceCard(
    String title,
    String category,
    IconData icon,
    Color color,
    String cost,
    String funding,
  ) {
    return Trending2025Components.buildAccessibleInfoCard(
      context: context,
      title: title,
      content: '$category • $cost • $funding',
      icon: icon,
      accentColor: color,
      onTap: () {
        // Handle service selection
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildAdvancedDateTimeSelection(DateTime? preSelectedDate) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Date & Time',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Date selection with enhanced picker
        EnhancedTextField(
          controller: TextEditingController(
            text: preSelectedDate != null
                ? _formatSelectedDate(preSelectedDate)
                : 'Select your preferred date',
          ),
          label: 'Appointment Date',
          hint: 'Tap to select date',
          prefixIcon: Icons.calendar_today,
          onTap: _selectBookingDate,
        ),

        const SizedBox(height: 16),

        // Time slot selection with availability
        if (preSelectedDate != null)
          TimeSlotSelector(
            selectedDate: preSelectedDate,
            availableSlots: _generateTimeSlots(preSelectedDate),
            onSlotSelected: (slot) {
              HapticFeedback.lightImpact();
            },
          ),
      ],
    );
  }

  Widget _buildNDISBookingOptions() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // NDIS-specific options
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildOptionChip('Transport Required', Icons.directions_bus),
            _buildOptionChip('Home Visit', Icons.home),
            _buildOptionChip('Telehealth', Icons.video_call),
            _buildOptionChip('Interpreter Needed', Icons.translate),
            _buildOptionChip('Carer Welcome', Icons.people),
            _buildOptionChip('Accessible Venue', Icons.accessibility_new),
          ],
        ),

        const SizedBox(height: 16),

        // Emergency contact info
        CinematicDataStoryTelling.buildContextualVisualCue(
          context: context,
          message: 'Emergency contact will be notified of your appointment',
          type: CueType.info,
        ),
      ],
    );
  }

  Widget _buildOptionChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: false, // TODO: Implement selection state
      onSelected: (selected) {
        HapticFeedback.lightImpact();
      },
    );
  }

  void _confirmEnhancedBooking() {
    Navigator.pop(context);
    HapticFeedback.heavyImpact();

    // Show success with contextual cue
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('🎉 NDIS session booked successfully! Confirmation sent.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }
}

enum CalendarView { month, week, day }

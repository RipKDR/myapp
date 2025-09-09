import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../controllers/gamification_controller.dart';
import '../theme/google_theme.dart';
import '../widgets/creative_components.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/financial_visualization_components.dart';
import '../routes.dart';

/// Enhanced dashboard with creative glassmorphism, 3D effects, and delightful animations
class CreativeEnhancedDashboard extends StatefulWidget {
  const CreativeEnhancedDashboard({super.key});

  @override
  State<CreativeEnhancedDashboard> createState() =>
      _CreativeEnhancedDashboardState();
}

class _CreativeEnhancedDashboardState extends State<CreativeEnhancedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _floatingController;
  late ScrollController _scrollController;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    // Stagger card animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Animated mesh gradient background
          Positioned.fill(
            child: AnimatedMeshGradient(
              colors: [
                GoogleTheme.googleBlue.withOpacity(0.1),
                GoogleTheme.googleGreen.withOpacity(0.1),
                GoogleTheme.googleYellow.withOpacity(0.1),
                GoogleTheme.googleRed.withOpacity(0.1),
              ],
              child: Container(),
            ),
          ),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildCreativeSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(context),
                    const SizedBox(height: 24),
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 24),
                    _buildInsightsSection(context),
                    const SizedBox(height: 24),
                    _buildInteractiveCardsSection(context),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),

          // Floating action menu
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildOrbitalMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax background
            Transform.translate(
              offset: Offset(0, _scrollOffset * 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GoogleTheme.googleBlue.withOpacity(0.8),
                      GoogleTheme.googleGreen.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Glassmorphic overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassmorphicContainer(
                height: 120,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your NDIS journey continues',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final gamification = context.watch<GamificationController>();

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 5 * math.sin(_floatingController.value * math.pi)),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 3D Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        GoogleTheme.googleBlue,
                        GoogleTheme.googleGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GoogleTheme.googleBlue.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Alex!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatChip(
                            icon: Icons.local_fire_department,
                            label: '${gamification.streakDays} day streak',
                            color: GoogleTheme.googleRed,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            icon: Icons.star,
                            label: '${gamification.points} points',
                            color: GoogleTheme.googleYellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickActionCard(
                icon: Icons.calendar_today,
                label: 'Book Session',
                color: GoogleTheme.googleBlue,
                onTap: () => Navigator.pushNamed(context, Routes.calendar),
              ),
              _buildQuickActionCard(
                icon: Icons.account_balance_wallet,
                label: 'Budget',
                color: GoogleTheme.googleGreen,
                onTap: () => Navigator.pushNamed(context, Routes.budget),
              ),
              _buildQuickActionCard(
                icon: Icons.chat_bubble,
                label: 'AI Assistant',
                color: GoogleTheme.ndisTeal,
                onTap: () => Navigator.pushNamed(context, Routes.chat),
              ),
              _buildQuickActionCard(
                icon: Icons.explore,
                label: 'Services',
                color: GoogleTheme.googleYellow,
                onTap: () => Navigator.pushNamed(context, Routes.map),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: LiquidButton(
        text: label,
        icon: icon,
        color: color,
        width: 140,
        height: 100,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Insights',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: 16,
          children: [
            // Budget overview with glassmorphism
            GlassmorphicContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GoogleTheme.googleGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: GoogleTheme.googleGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Budget Status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BudgetDonutChart(
                          categories: [
                            BudgetCategory(
                              name: 'Core',
                              allocated: 10000,
                              spent: 7500,
                              color: GoogleTheme.googleBlue,
                            ),
                            BudgetCategory(
                              name: 'Capacity',
                              allocated: 5000,
                              spent: 3000,
                              color: GoogleTheme.googleGreen,
                            ),
                            BudgetCategory(
                              name: 'Capital',
                              allocated: 3000,
                              spent: 1000,
                              color: GoogleTheme.googleYellow,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '75%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: GoogleTheme.googleBlue,
                                  ),
                            ),
                            Text(
                              'Used',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Upcoming sessions with parallax
            ParallaxCard(
              imageUrl: '',
              title: 'Next Session',
              subtitle: 'Tomorrow at 2:00 PM',
              height: 180,
              onTap: () => Navigator.pushNamed(context, Routes.calendar),
            ),

            // Progress tracker with 3D flip
            Flip3DCard(
              width: double.infinity,
              height: 180,
              front: GlassmorphicContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: GoogleTheme.ndisPurple,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weekly Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to see details',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              back: GlassmorphicContainer(
                padding: const EdgeInsets.all(16),
                color: GoogleTheme.ndisPurple,
                opacity: 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4 Goals Achieved!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep up the great work',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractiveCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Services',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Service cards with neumorphic switches
        _buildServiceCard(
          context,
          title: 'Daily Living Support',
          provider: 'Care Plus Services',
          nextSession: 'Monday, 10:00 AM',
          isActive: true,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          context,
          title: 'Therapy Sessions',
          provider: 'Wellness Clinic',
          nextSession: 'Wednesday, 2:00 PM',
          isActive: true,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          context,
          title: 'Transport Assistance',
          provider: 'NDIS Transport Co',
          nextSession: 'On demand',
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String provider,
    required String nextSession,
    required bool isActive,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [GoogleTheme.googleBlue, GoogleTheme.googleGreen]
                    : [Colors.grey.shade400, Colors.grey.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.check : Icons.schedule,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  provider,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Next: $nextSession',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          NeumorphicSwitch(
            value: isActive,
            onChanged: (value) {
              // Handle service toggle
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitalMenu(BuildContext context) {
    return OrbitalActionMenu(
      actions: [
        OrbitalAction(
          icon: Icons.add,
          color: GoogleTheme.googleBlue,
          onPressed: () {
            // Add new appointment
          },
        ),
        OrbitalAction(
          icon: Icons.message,
          color: GoogleTheme.googleGreen,
          onPressed: () => Navigator.pushNamed(context, Routes.chat),
        ),
        OrbitalAction(
          icon: Icons.qr_code_scanner,
          color: GoogleTheme.googleYellow,
          onPressed: () {
            // Scan QR code
          },
        ),
        OrbitalAction(
          icon: Icons.emergency,
          color: GoogleTheme.googleRed,
          onPressed: () {
            // Emergency contact
          },
        ),
      ],
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [GoogleTheme.googleBlue, GoogleTheme.googleGreen],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: GoogleTheme.googleBlue.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

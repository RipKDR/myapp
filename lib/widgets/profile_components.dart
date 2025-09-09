import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';
import 'responsive_layout.dart';

/// Advanced profile and settings components following 2025 design trends
/// Features comprehensive customization and accessibility options

/// Enhanced profile header with avatar and quick stats
class ProfileHeader extends StatefulWidget {
  final String name;
  final String? email;
  final String? role;
  final Widget? avatar;
  final List<ProfileStat> stats;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.name,
    this.email,
    this.role,
    this.avatar,
    this.stats = const [],
    this.onEditProfile,
    this.onAvatarTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
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
    final isMobile = context.isMobile;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GoogleTheme.googleBlue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Avatar and basic info
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onAvatarTap,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GoogleTheme.googleBlue.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GoogleTheme.googleBlue.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: widget.avatar ??
                              CircleAvatar(
                                radius: isMobile ? 32 : 40,
                                backgroundColor:
                                    GoogleTheme.googleBlue.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: isMobile ? 32 : 40,
                                  color: GoogleTheme.googleBlue,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (widget.email != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.email!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (widget.role != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      GoogleTheme.googleBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.role!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: GoogleTheme.googleBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.onEditProfile != null)
                        IconButton(
                          onPressed: widget.onEditProfile,
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Profile',
                        ),
                    ],
                  ),

                  // Stats section
                  if (widget.stats.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildStatsSection(context),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: _buildStatItems(context),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildStatItems(context),
            ),
    );
  }

  List<Widget> _buildStatItems(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return widget.stats
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final stat = entry.value;

          return [
            if (index > 0 && !isMobile)
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            if (index > 0 && isMobile) const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: stat.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ];
        })
        .expand((widgets) => widgets)
        .toList();
  }
}

/// Enhanced settings section with organized categories
class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<SettingsItem> items;
  final EdgeInsetsGeometry? padding;
  final Color? headerColor;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.padding,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (headerColor ?? GoogleTheme.googleBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: headerColor ?? GoogleTheme.googleBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Settings items
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    _buildSettingsItem(context, item),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, SettingsItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: item.leadingIcon != null
          ? Icon(
              item.leadingIcon,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            )
          : null,
      title: Text(
        item.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: item.trailing,
      onTap: item.onTap,
      enabled: item.enabled,
    );
  }
}

/// Advanced preference toggle with enhanced styling
class PreferenceToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? activeColor;
  final bool enabled;

  const PreferenceToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
    this.activeColor,
    this.enabled = true,
  });

  @override
  State<PreferenceToggle> createState() => _PreferenceToggleState();
}

class _PreferenceToggleState extends State<PreferenceToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.value) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PreferenceToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
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

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.value && widget.enabled
                  ? (widget.activeColor ?? GoogleTheme.googleBlue)
                      .withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.value && widget.enabled
                    ? (widget.activeColor ?? GoogleTheme.googleBlue)
                        .withOpacity(0.2)
                    : colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.enabled
                        ? (widget.value
                            ? (widget.activeColor ?? GoogleTheme.googleBlue)
                            : colorScheme.onSurfaceVariant)
                        : colorScheme.onSurfaceVariant.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.enabled
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: widget.value,
                  onChanged: widget.enabled
                      ? (value) {
                          HapticFeedback.lightImpact();
                          widget.onChanged(value);
                        }
                      : null,
                  activeColor: widget.activeColor ?? GoogleTheme.googleBlue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced slider preference with visual feedback
class SliderPreference extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String title;
  final String? subtitle;
  final double min;
  final double max;
  final int divisions;
  final String Function(double)? formatter;
  final IconData? icon;
  final Color? activeColor;

  const SliderPreference({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
    this.formatter,
    this.icon,
    this.activeColor,
  });

  @override
  State<SliderPreference> createState() => _SliderPreferenceState();
}

class _SliderPreferenceState extends State<SliderPreference> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                widget.formatter?.call(widget.value) ??
                    widget.value.toStringAsFixed(1),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.activeColor ?? GoogleTheme.googleBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.activeColor ?? GoogleTheme.googleBlue,
              inactiveTrackColor: colorScheme.outline.withOpacity(0.2),
              thumbColor: widget.activeColor ?? GoogleTheme.googleBlue,
              overlayColor: (widget.activeColor ?? GoogleTheme.googleBlue)
                  .withOpacity(0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                widget.onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile action card for quick settings access
class ProfileActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;
  final bool enabled;

  const ProfileActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
    this.enabled = true,
  });

  @override
  State<ProfileActionCard> createState() => _ProfileActionCardState();
}

class _ProfileActionCardState extends State<ProfileActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _handleTapDown(),
            onTapUp: (_) => _handleTapUp(),
            onTapCancel: () => _handleTapUp(),
            onTap: widget.enabled ? widget.onTap : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? colorScheme.surface
                    : colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.enabled
                              ? widget.color.withOpacity(0.1)
                              : widget.color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.enabled
                              ? widget.color
                              : widget.color.withOpacity(0.5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.enabled
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.enabled
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: widget.enabled
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  if (widget.badge != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: widget.badge!,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown() {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }
}

// Data models for profile components
class ProfileStat {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const ProfileStat({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });
}

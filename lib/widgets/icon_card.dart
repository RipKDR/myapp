import 'package:flutter/material.dart';

class IconCard extends StatefulWidget {

  const IconCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.color,
    this.iconColor,
    this.onTap,
    this.showBadge = false,
    this.badgeText,
    this.isPremium = false,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final String? badgeText;
  final bool isPremium;
  final bool isLoading;

  @override
  State<IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<IconCard>
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
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(final TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(final TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHighContrast = Theme.of(context).brightness == Brightness.light
        ? scheme.primary == const Color(0xFF000080)
        : scheme.primary == const Color(0xFF3B82F6);

    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.subtitle,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (final context, final child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              color: widget.color ?? scheme.surface,
              elevation: _isPressed ? 2 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icon with optional badge
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (widget.iconColor ?? scheme.primary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isHighContrast
                                  ? Border.all(
                                      color: widget.iconColor ?? scheme.primary,
                                      width: 2)
                                  : null,
                            ),
                            child: Icon(
                              widget.icon,
                              size: 28,
                              color: widget.iconColor ?? scheme.primary,
                            ),
                          ),
                          if (widget.showBadge && widget.badgeText != null)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: scheme.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.badgeText!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: scheme.onError,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          if (widget.isPremium)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: scheme.tertiary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: scheme.onTertiary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Loading or chevron
                      if (widget.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.chevron_right,
                          color: scheme.onSurfaceVariant,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }
}

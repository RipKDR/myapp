import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Cinematic data storytelling components for 2025+ visual narratives
/// Creates engaging, story-driven data visualizations with cinematic effects
class CinematicDataStoryTelling {
  /// Creates a narrative progress arc that tells the user's NDIS journey story
  static Widget buildProgressNarrativeArc({
    required final BuildContext context,
    required final List<StoryPoint> storyPoints,
    required final double currentProgress,
    final Color? accentColor,
    final bool showAnimations = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (accentColor ?? colorScheme.primary).withValues(alpha: 0.1),
            Colors.transparent,
            (accentColor ?? colorScheme.primary).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (accentColor ?? colorScheme.primary).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story title with cinematic typography
          Text(
            'Your NDIS Journey',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              background: Paint()
                ..shader = LinearGradient(
                  colors: [
                    accentColor ?? colorScheme.primary,
                    (accentColor ?? colorScheme.primary).withValues(alpha: 0.7),
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),

          const SizedBox(height: 20),

          // Interactive story timeline
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: storyPoints.length,
              itemBuilder: (final context, final index) {
                final point = storyPoints[index];
                final isCompleted =
                    (index / storyPoints.length) <= currentProgress;
                final isCurrent =
                    index == (currentProgress * storyPoints.length).floor();

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.only(right: 16),
                  width: 100,
                  child: Column(
                    children: [
                      // Story point indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (accentColor ?? colorScheme.primary)
                              : colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? (accentColor ?? colorScheme.primary)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: (accentColor ?? colorScheme.primary)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          point.icon,
                          color: isCompleted
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Story point title
                      Text(
                        point.title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight:
                              isCompleted ? FontWeight.w600 : FontWeight.w400,
                          color: isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Progress indicator
                      if (isCurrent)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accentColor ?? colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Current chapter description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(currentProgress),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCurrentChapterTitle(currentProgress, storyPoints),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor ?? colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCurrentChapterDescription(currentProgress, storyPoints),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates animated data stories with contextual visual cues
  static Widget buildAnimatedDataStory({
    required final BuildContext context,
    required final String title,
    required final String value,
    required final String previousValue,
    required final String trendDescription,
    required final IconData icon,
    final Color? color,
    final bool showCelebration = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final storyColor = color ?? colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              storyColor.withValues(alpha: 0.1),
              storyColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: storyColor.withValues(alpha: 0.2),
          ),
          boxShadow: showCelebration
              ? [
                  BoxShadow(
                    color: storyColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Animated icon with story context
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  transform: Matrix4.identity()
                    ..scale(showCelebration ? 1.2 : 1.0),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: storyColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: storyColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: storyColor,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trendDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Celebration particles
                if (showCelebration)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    child: Stack(
                      children: List.generate(3, (final index) => AnimatedPositioned(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          right: 10.0 + (index * 8),
                          top: 10.0 + (index * 12),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: storyColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Value comparison with cinematic transition
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 600),
                  style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: storyColor,
                      ) ??
                      const TextStyle(),
                  child: Text(value),
                ),

                const SizedBox(width: 12),

                // Previous value with fade effect
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 0.6,
                  child: Text(
                    'was $previousValue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress visualization
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    storyColor.withValues(alpha: 0.3),
                    storyColor,
                    storyColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates contextual visual cues that guide user attention
  static Widget buildContextualVisualCue({
    required final BuildContext context,
    required final String message,
    required final CueType type,
    final VoidCallback? onAction,
    final bool isAnimated = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color cueColor;
    IconData cueIcon;

    switch (type) {
      case CueType.success:
        cueColor = GoogleTheme.googleGreen;
        cueIcon = Icons.check_circle;
        break;
      case CueType.attention:
        cueColor = GoogleTheme.googleYellow;
        cueIcon = Icons.lightbulb;
        break;
      case CueType.urgent:
        cueColor = GoogleTheme.googleRed;
        cueIcon = Icons.priority_high;
        break;
      case CueType.info:
        cueColor = GoogleTheme.googleBlue;
        cueIcon = Icons.info;
        break;
      case CueType.celebration:
        cueColor = GoogleTheme.ndisPurple;
        cueIcon = Icons.celebration;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      transform: Matrix4.identity()..translate(0.0, isAnimated ? 0.0 : 10.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cueColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cueColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: type == CueType.urgent
              ? [
                  BoxShadow(
                    color: cueColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              transform: Matrix4.identity()
                ..scale(type == CueType.celebration ? 1.2 : 1.0),
              child: Icon(
                cueIcon,
                color: cueColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (onAction != null)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction();
                },
                child: Text(
                  'Action',
                  style: TextStyle(
                    color: cueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Creates immersive data experience with parallax effects
  static Widget buildParallaxDataExperience({
    required final BuildContext context,
    required final ScrollController scrollController,
    required final List<Widget> dataLayers,
    final double parallaxFactor = 0.5,
  }) => AnimatedBuilder(
      animation: scrollController,
      builder: (final context, final child) {
        final offset =
            scrollController.hasClients ? scrollController.offset : 0.0;

        return Stack(
          children: dataLayers.asMap().entries.map((final entry) {
            final index = entry.key;
            final layer = entry.value;
            final layerOffset = offset * parallaxFactor * (index + 1);

            return Transform.translate(
              offset: Offset(0, layerOffset * 0.1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0 - (layerOffset * 0.001).clamp(0.0, 0.3),
                child: layer,
              ),
            );
          }).toList(),
        );
      },
    );

  // Helper methods
  static String _getCurrentChapterTitle(
      final double progress, final List<StoryPoint> points) {
    final index =
        (progress * points.length).floor().clamp(0, points.length - 1);
    return points[index].title;
  }

  static String _getCurrentChapterDescription(
      final double progress, final List<StoryPoint> points) {
    final index =
        (progress * points.length).floor().clamp(0, points.length - 1);
    return points[index].description;
  }
}

/// Represents a point in the user's NDIS story
class StoryPoint {

  const StoryPoint({
    required this.title,
    required this.description,
    required this.icon,
    this.completedAt,
  });
  final String title;
  final String description;
  final IconData icon;
  final DateTime? completedAt;
}

/// Types of contextual visual cues
enum CueType {
  success,
  attention,
  urgent,
  info,
  celebration,
}

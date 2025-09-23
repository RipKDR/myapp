import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with caching, compression, and performance improvements
class OptimizedImage extends StatelessWidget {

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;

  @override
  Widget build(final BuildContext context) => ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration,
        placeholderFadeInDuration: placeholderFadeInDuration,
        memCacheWidth: memCacheWidth ?? width?.toInt(),
        memCacheHeight: memCacheHeight ?? height?.toInt(),
        maxWidthDiskCache: maxWidthDiskCache ?? 800,
        maxHeightDiskCache: maxHeightDiskCache ?? 600,
        placeholder: (final context, final url) =>
            placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (final context, final url, final error) =>
            errorWidget ?? _buildDefaultErrorWidget(),
        // Performance optimizations
        useOldImageOnUrlChange: true,
        filterQuality: FilterQuality.medium,
        httpHeaders: const {
          'Cache-Control': 'max-age=31536000', // 1 year cache
        },
      ),
    );

  /// Build default shimmer placeholder
  Widget _buildDefaultPlaceholder() => Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );

  /// Build default error widget
  Widget _buildDefaultErrorWidget() => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 24,
      ),
    );
}

/// Optimized avatar widget for profile images
class OptimizedAvatar extends StatelessWidget {

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(final BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: OptimizedImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          borderRadius: BorderRadius.circular(radius),
          memCacheWidth: (radius * 2).toInt(),
          memCacheHeight: (radius * 2).toInt(),
          maxWidthDiskCache: 200,
          maxHeightDiskCache: 200,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: name != null && name!.isNotEmpty
          ? Text(
              _getInitials(name!),
              style: textStyle ??
                  TextStyle(
                    color: foregroundColor ?? Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
            )
          : Icon(
              Icons.person,
              color: foregroundColor ?? Colors.white,
              size: radius * 0.8,
            ),
    );
  }

  String _getInitials(final String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';

    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

/// Optimized image gallery widget for multiple images
class OptimizedImageGallery extends StatelessWidget {

  const OptimizedImageGallery({
    super.key,
    required this.imageUrls,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.maxImages = 4,
    this.onTap,
    this.showOverlay = true,
  });
  final List<String> imageUrls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int maxImages;
  final VoidCallback? onTap;
  final bool showOverlay;

  @override
  Widget build(final BuildContext context) {
    if (imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    final displayImages = imageUrls.take(maxImages).toList();
    final remainingCount = imageUrls.length - maxImages;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImageGrid(displayImages, remainingCount),
      ),
    );
  }

  Widget _buildEmptyState() => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        color: Colors.grey[400],
        size: 24,
      ),
    );

  Widget _buildImageGrid(final List<String> images, final int remainingCount) {
    if (images.length == 1) {
      return OptimizedImage(
        imageUrl: images[0],
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: OptimizedImage(
              imageUrl: images[0],
              height: height,
              fit: fit,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: OptimizedImage(
              imageUrl: images[1],
              height: height,
              fit: fit,
            ),
          ),
        ],
      );
    }

    if (images.length == 3) {
      return Column(
        children: [
          Expanded(
            child: OptimizedImage(
              imageUrl: images[0],
              width: width,
              fit: fit,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: OptimizedImage(
                    imageUrl: images[1],
                    fit: fit,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: OptimizedImage(
                    imageUrl: images[2],
                    fit: fit,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4 or more images
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: OptimizedImage(
                  imageUrl: images[0],
                  fit: fit,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: OptimizedImage(
                  imageUrl: images[1],
                  fit: fit,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: OptimizedImage(
                  imageUrl: images[2],
                  fit: fit,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    OptimizedImage(
                      imageUrl: images[3],
                      fit: fit,
                    ),
                    if (remainingCount > 0 && showOverlay)
                      ColoredBox(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            '+$remainingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Performance monitoring for image loading
class ImagePerformanceMonitor {
  static final Map<String, List<Duration>> _loadTimes = {};
  static final Map<String, int> _errorCounts = {};

  static void recordLoadTime(final String imageUrl, final Duration loadTime) {
    _loadTimes.putIfAbsent(imageUrl, () => []).add(loadTime);
  }

  static void recordError(final String imageUrl) {
    _errorCounts[imageUrl] = (_errorCounts[imageUrl] ?? 0) + 1;
  }

  static Map<String, dynamic> getStats() {
    final avgLoadTimes = <String, Duration>{};
    _loadTimes.forEach((final url, final times) {
      final total = times.fold<Duration>(
        Duration.zero,
        (final sum, final time) => sum + time,
      );
      avgLoadTimes[url] = Duration(
        microseconds: total.inMicroseconds ~/ times.length,
      );
    });

    return {
      'averageLoadTimes': avgLoadTimes,
      'errorCounts': _errorCounts,
      'totalImages': _loadTimes.length,
      'totalErrors': _errorCounts.values.fold(0, (final sum, final count) => sum + count),
    };
  }

  static void clearStats() {
    _loadTimes.clear();
    _errorCounts.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Enhanced form components following 2025 design trends and shadcn/ui principles
/// Features advanced micro-interactions, accessibility, and modern aesthetics

/// Enhanced text field with advanced animations and accessibility
class EnhancedTextField extends StatefulWidget {

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _focusNode.addListener(_onFocusChange);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: GoogleTheme.googleBlue,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);

    if (_isFocused) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (final context, final child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floating label
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                bottom: _isFocused || widget.controller.text.isNotEmpty ? 8 : 0,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity:
                    _isFocused || widget.controller.text.isNotEmpty ? 1.0 : 0.0,
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _hasError
                        ? colorScheme.error
                        : _isFocused
                            ? GoogleTheme.googleBlue
                            : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Text field container
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: GoogleTheme.googleBlue.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                textInputAction: widget.textInputAction,
                onTap: widget.onTap,
                onChanged: (final value) {
                  widget.onChanged?.call(value);
                  if (_hasError) {
                    _validateField();
                  }
                },
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: widget.enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint ?? widget.label,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            widget.prefixIcon,
                            color: _hasError
                                ? colorScheme.error
                                : _isFocused
                                    ? GoogleTheme.googleBlue
                                    : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: widget.enabled
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          _borderColorAnimation.value ?? GoogleTheme.googleBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: const TextStyle(height: 0),
                ),
                validator: widget.validator,
              ),
            ),

            // Error message with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _hasError ? 24 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hasError ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _errorText ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

/// Enhanced button with loading states and micro-interactions
class EnhancedButton extends StatefulWidget {

  const EnhancedButton({
    super.key,
    this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.tooltip,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final String? tooltip;

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    _elevationAnimation = Tween<double>(
      begin: 1,
      end: 4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(final TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget button = AnimatedBuilder(
      animation: _animationController,
      builder: (final context, final child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: !widget.isSecondary && widget.onPressed != null
                  ? [
                      BoxShadow(
                        color: GoogleTheme.googleBlue.withValues(alpha: 0.2),
                        blurRadius: _elevationAnimation.value * 2,
                        offset: Offset(0, _elevationAnimation.value),
                      ),
                    ]
                  : null,
            ),
            child: widget.isSecondary
                ? OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onPressed,
                    style: widget.style ??
                        OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    child: _buildButtonContent(),
                  )
                : FilledButton(
                    onPressed: widget.isLoading ? null : widget.onPressed,
                    style: widget.style ??
                        FilledButton.styleFrom(
                          backgroundColor: GoogleTheme.googleBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    child: _buildButtonContent(),
                  ),
          ),
        ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: widget.tooltip != null
          ? Tooltip(
              message: widget.tooltip,
              child: button,
            )
          : button,
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.isSecondary
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
          widget.child,
        ],
      );
    }

    return widget.child;
  }
}

/// Social login button with brand styling
class SocialLoginButton extends StatelessWidget {

  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });
  final String provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color? backgroundColor;
    Color? foregroundColor;

    switch (provider.toLowerCase()) {
      case 'google':
        icon = Icons.g_mobiledata;
        backgroundColor = Colors.white;
        foregroundColor = Colors.black87;
        break;
      case 'apple':
        icon = Icons.apple;
        backgroundColor = Colors.black;
        foregroundColor = Colors.white;
        break;
      case 'microsoft':
        icon = Icons.business;
        backgroundColor = const Color(0xFF0078D4);
        foregroundColor = Colors.white;
        break;
      default:
        icon = Icons.login;
        backgroundColor = colorScheme.surface;
        foregroundColor = colorScheme.onSurface;
    }

    return EnhancedButton(
      onPressed: onPressed,
      isLoading: isLoading,
      isSecondary: true,
      icon: icon,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: BorderSide(
          color: provider.toLowerCase() == 'google'
              ? colorScheme.outline
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text('Continue with $provider'),
    );
  }
}

/// Enhanced checkbox with animations
class EnhancedCheckbox extends StatefulWidget {

  const EnhancedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String? subtitle;

  @override
  State<EnhancedCheckbox> createState() => _EnhancedCheckboxState();
}

class _EnhancedCheckboxState extends State<EnhancedCheckbox>
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
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.value) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(final EnhancedCheckbox oldWidget) {
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
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (final context, final child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Checkbox(
                  value: widget.value,
                  onChanged: widget.onChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

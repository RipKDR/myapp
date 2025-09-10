import 'dart:convert';
import 'package:flutter/material.dart';

/// Comprehensive data validation service for NDIS Connect app
class ValidationService {
  factory ValidationService() => _instance;
  ValidationService._internal();
  static final ValidationService _instance = ValidationService._internal();

  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone number validation regex (Australian format)
  static final RegExp _phoneRegex = RegExp(r'^(\+61|0)[2-9]\d{8}$');

  // NDIS number validation regex
  static final RegExp _ndisNumberRegex = RegExp(r'^\d{9}$');

  // Password strength requirements
  static const int _minPasswordLength = 8;
  static const int _maxPasswordLength = 128;

  /// Validate email address
  ValidationResult validateEmail(final String email) {
    if (email.isEmpty) {
      return ValidationResult.error('Email is required');
    }

    if (!_emailRegex.hasMatch(email)) {
      return ValidationResult.error('Please enter a valid email address');
    }

    if (email.length > 254) {
      return ValidationResult.error('Email address is too long');
    }

    return ValidationResult.success();
  }

  /// Validate password strength
  ValidationResult validatePassword(final String password) {
    if (password.isEmpty) {
      return ValidationResult.error('Password is required');
    }

    if (password.length < _minPasswordLength) {
      return ValidationResult.error(
        'Password must be at least $_minPasswordLength characters long',
      );
    }

    if (password.length > _maxPasswordLength) {
      return ValidationResult.error('Password is too long');
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp('[A-Z]'))) {
      return ValidationResult.error(
        'Password must contain at least one uppercase letter',
      );
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp('[a-z]'))) {
      return ValidationResult.error(
        'Password must contain at least one lowercase letter',
      );
    }

    // Check for at least one digit
    if (!password.contains(RegExp('[0-9]'))) {
      return ValidationResult.error('Password must contain at least one digit');
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return ValidationResult.error(
        'Password must contain at least one special character',
      );
    }

    return ValidationResult.success();
  }

  /// Validate phone number (Australian format)
  ValidationResult validatePhoneNumber(final String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return ValidationResult.error('Phone number is required');
    }

    // Remove spaces and dashes
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');

    if (!_phoneRegex.hasMatch(cleaned)) {
      return ValidationResult.error(
        'Please enter a valid Australian phone number',
      );
    }

    return ValidationResult.success();
  }

  /// Validate NDIS number
  ValidationResult validateNDISNumber(final String ndisNumber) {
    if (ndisNumber.isEmpty) {
      return ValidationResult.error('NDIS number is required');
    }

    // Remove spaces
    final cleaned = ndisNumber.replaceAll(' ', '');

    if (!_ndisNumberRegex.hasMatch(cleaned)) {
      return ValidationResult.error('NDIS number must be 9 digits');
    }

    return ValidationResult.success();
  }

  /// Validate name (first name, last name, etc.)
  ValidationResult validateName(final String name, {final String fieldName = 'Name'}) {
    if (name.isEmpty) {
      return ValidationResult.error('$fieldName is required');
    }

    if (name.length < 2) {
      return ValidationResult.error(
        '$fieldName must be at least 2 characters long',
      );
    }

    if (name.length > 50) {
      return ValidationResult.error('$fieldName is too long');
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return ValidationResult.error('$fieldName contains invalid characters');
    }

    return ValidationResult.success();
  }

  /// Validate date of birth
  ValidationResult validateDateOfBirth(final DateTime dateOfBirth) {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;

    if (age < 0) {
      return ValidationResult.error('Date of birth cannot be in the future');
    }

    if (age > 120) {
      return ValidationResult.error('Please enter a valid date of birth');
    }

    if (age < 0) {
      return ValidationResult.error('Age must be at least 0');
    }

    return ValidationResult.success();
  }

  /// Validate appointment data
  ValidationResult validateAppointment({
    required final String title,
    required final String description,
    required final DateTime startTime,
    required final DateTime endTime,
    final String? location,
  }) {
    // Validate title
    if (title.isEmpty) {
      return ValidationResult.error('Appointment title is required');
    }

    if (title.length > 100) {
      return ValidationResult.error('Appointment title is too long');
    }

    // Validate description
    if (description.isEmpty) {
      return ValidationResult.error('Appointment description is required');
    }

    if (description.length > 500) {
      return ValidationResult.error('Appointment description is too long');
    }

    // Validate time
    if (startTime.isAfter(endTime)) {
      return ValidationResult.error('Start time must be before end time');
    }

    if (startTime.isBefore(DateTime.now())) {
      return ValidationResult.error(
        'Appointment cannot be scheduled in the past',
      );
    }

    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 15) {
      return ValidationResult.error(
        'Appointment must be at least 15 minutes long',
      );
    }

    if (duration.inHours > 8) {
      return ValidationResult.error(
        'Appointment cannot be longer than 8 hours',
      );
    }

    // Validate location
    if (location != null && location.length > 200) {
      return ValidationResult.error('Location is too long');
    }

    return ValidationResult.success();
  }

  /// Validate budget entry
  ValidationResult validateBudgetEntry({
    required final double amount,
    required final String category,
    final String? description,
  }) {
    // Validate amount
    if (amount <= 0) {
      return ValidationResult.error('Amount must be greater than 0');
    }

    if (amount > 100000) {
      return ValidationResult.error('Amount is too large');
    }

    // Validate category
    if (category.isEmpty) {
      return ValidationResult.error('Category is required');
    }

    // Validate description
    if (description != null && description.length > 200) {
      return ValidationResult.error('Description is too long');
    }

    return ValidationResult.success();
  }

  /// Validate task data
  ValidationResult validateTask({
    required final String title,
    required final String description,
    required final int priority,
    final DateTime? dueDate,
    final String? category,
  }) {
    // Validate title
    if (title.isEmpty) {
      return ValidationResult.error('Task title is required');
    }

    if (title.length > 100) {
      return ValidationResult.error('Task title is too long');
    }

    // Validate description
    if (description.isEmpty) {
      return ValidationResult.error('Task description is required');
    }

    if (description.length > 500) {
      return ValidationResult.error('Task description is too long');
    }

    // Validate priority
    if (priority < 1 || priority > 5) {
      return ValidationResult.error('Priority must be between 1 and 5');
    }

    // Validate due date
    if (dueDate != null && dueDate.isBefore(DateTime.now())) {
      return ValidationResult.error('Due date cannot be in the past');
    }

    // Validate category
    if (category != null && category.length > 50) {
      return ValidationResult.error('Category is too long');
    }

    return ValidationResult.success();
  }

  /// Validate support circle data
  ValidationResult validateSupportCircle({
    required final String name,
    required final List<Map<String, dynamic>> members,
  }) {
    // Validate name
    if (name.isEmpty) {
      return ValidationResult.error('Support circle name is required');
    }

    if (name.length > 100) {
      return ValidationResult.error('Support circle name is too long');
    }

    // Validate members
    if (members.isEmpty) {
      return ValidationResult.error(
        'Support circle must have at least one member',
      );
    }

    if (members.length > 20) {
      return ValidationResult.error(
        'Support circle cannot have more than 20 members',
      );
    }

    // Validate each member
    for (int i = 0; i < members.length; i++) {
      final member = members[i];
      final nameResult = validateName(
        member['name'] ?? '',
        fieldName: 'Member ${i + 1} name',
      );
      if (!nameResult.isValid) {
        return nameResult;
      }

      final emailResult = validateEmail(member['email'] ?? '');
      if (!emailResult.isValid) {
        return ValidationResult.error(
          'Member ${i + 1} email: ${emailResult.errorMessage}',
        );
      }
    }

    return ValidationResult.success();
  }

  /// Validate shift data
  ValidationResult validateShift({
    required final DateTime startTime,
    required final DateTime endTime,
    required final String location,
    required final int maxParticipants,
  }) {
    // Validate time
    if (startTime.isAfter(endTime)) {
      return ValidationResult.error('Start time must be before end time');
    }

    final duration = endTime.difference(startTime);
    if (duration.inHours < 1) {
      return ValidationResult.error('Shift must be at least 1 hour long');
    }

    if (duration.inHours > 12) {
      return ValidationResult.error('Shift cannot be longer than 12 hours');
    }

    // Validate location
    if (location.isEmpty) {
      return ValidationResult.error('Location is required');
    }

    if (location.length > 200) {
      return ValidationResult.error('Location is too long');
    }

    // Validate max participants
    if (maxParticipants < 1) {
      return ValidationResult.error('Maximum participants must be at least 1');
    }

    if (maxParticipants > 50) {
      return ValidationResult.error('Maximum participants cannot exceed 50');
    }

    return ValidationResult.success();
  }

  /// Sanitize input to prevent XSS
  String sanitizeInput(final String input) => input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');

  /// Validate JSON data
  ValidationResult validateJSON(final String jsonString) {
    try {
      jsonDecode(jsonString);
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Invalid JSON format');
    }
  }

  /// Validate URL
  ValidationResult validateURL(final String url) {
    if (url.isEmpty) {
      return ValidationResult.error('URL is required');
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return ValidationResult.error(
          'URL must start with http:// or https://',
        );
      }
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Invalid URL format');
    }
  }

  /// Validate file size (in bytes)
  ValidationResult validateFileSize(final int fileSize, {final int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (fileSize > maxSizeBytes) {
      return ValidationResult.error('File size cannot exceed ${maxSizeMB}MB');
    }

    return ValidationResult.success();
  }

  /// Validate file type
  ValidationResult validateFileType(
    final String fileName,
    final List<String> allowedExtensions,
  ) {
    if (fileName.isEmpty) {
      return ValidationResult.error('File name is required');
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return ValidationResult.error(
        'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}',
      );
    }

    return ValidationResult.success();
  }
}

/// Validation result class
class ValidationResult {

  ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => ValidationResult._(true, null);
  factory ValidationResult.error(final String message) =>
      ValidationResult._(false, message);
  final bool isValid;
  final String? errorMessage;
}

/// Form validation mixin
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String> _validationErrors = {};

  /// Validate a form field
  bool validateField(
    final String fieldName,
    final String value,
    final ValidationResult Function(String) validator,
  ) {
    final result = validator(value);
    if (result.isValid) {
      _validationErrors.remove(fieldName);
    } else {
      _validationErrors[fieldName] = result.errorMessage!;
    }
    setState(() {});
    return result.isValid;
  }

  /// Get error message for a field
  String? getFieldError(final String fieldName) => _validationErrors[fieldName];

  /// Check if form is valid
  bool get isFormValid => _validationErrors.isEmpty;

  /// Clear all validation errors
  void clearValidationErrors() {
    _validationErrors.clear();
    setState(() {});
  }

  /// Clear error for specific field
  void clearFieldError(final String fieldName) {
    _validationErrors.remove(fieldName);
    setState(() {});
  }
}

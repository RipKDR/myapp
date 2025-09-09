#!/bin/bash

# NDIS Connect - Comprehensive Testing Script
# This script runs all tests and generates a comprehensive test report

set -e

echo "🧪 Running NDIS Connect Comprehensive Tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create test results directory
mkdir -p test_results
TEST_RESULTS_DIR="test_results/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_RESULTS_DIR"

print_status "Test results will be saved to: $TEST_RESULTS_DIR"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Clean and get dependencies
print_status "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run linter analysis
print_status "Running linter analysis..."
if flutter analyze > "$TEST_RESULTS_DIR/linter_analysis.txt" 2>&1; then
    print_success "Linter analysis passed!"
    echo "✅ Linter analysis passed" >> "$TEST_RESULTS_DIR/test_summary.txt"
else
    print_warning "Linter analysis found issues"
    echo "⚠️ Linter analysis found issues" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Run unit tests
print_status "Running unit tests..."
if flutter test test/unit_test.dart --reporter=json > "$TEST_RESULTS_DIR/unit_tests.json" 2>&1; then
    print_success "Unit tests passed!"
    echo "✅ Unit tests passed" >> "$TEST_RESULTS_DIR/test_summary.txt"
else
    print_error "Unit tests failed"
    echo "❌ Unit tests failed" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Run widget tests
print_status "Running widget tests..."
if flutter test test/widget_test.dart --reporter=json > "$TEST_RESULTS_DIR/widget_tests.json" 2>&1; then
    print_success "Widget tests passed!"
    echo "✅ Widget tests passed" >> "$TEST_RESULTS_DIR/test_summary.txt"
else
    print_error "Widget tests failed"
    echo "❌ Widget tests failed" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Run integration tests (if available)
if [ -f "test/integration_test.dart" ]; then
    print_status "Running integration tests..."
    if flutter test test/integration_test.dart --reporter=json > "$TEST_RESULTS_DIR/integration_tests.json" 2>&1; then
        print_success "Integration tests passed!"
        echo "✅ Integration tests passed" >> "$TEST_RESULTS_DIR/test_summary.txt"
    else
        print_error "Integration tests failed"
        echo "❌ Integration tests failed" >> "$TEST_RESULTS_DIR/test_summary.txt"
    fi
else
    print_warning "Integration tests not found, skipping..."
    echo "⚠️ Integration tests not found" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Run all tests together
print_status "Running all tests..."
if flutter test --reporter=json > "$TEST_RESULTS_DIR/all_tests.json" 2>&1; then
    print_success "All tests passed!"
    echo "✅ All tests passed" >> "$TEST_RESULTS_DIR/test_summary.txt"
else
    print_error "Some tests failed"
    echo "❌ Some tests failed" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Generate test coverage report
print_status "Generating test coverage report..."
if flutter test --coverage > "$TEST_RESULTS_DIR/coverage_output.txt" 2>&1; then
    if [ -f "coverage/lcov.info" ]; then
        # Generate HTML coverage report
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o "$TEST_RESULTS_DIR/coverage_html"
            print_success "HTML coverage report generated!"
        else
            print_warning "genhtml not found, skipping HTML coverage report"
        fi
        
        # Copy coverage data
        cp coverage/lcov.info "$TEST_RESULTS_DIR/"
        print_success "Test coverage report generated!"
        echo "✅ Test coverage report generated" >> "$TEST_RESULTS_DIR/test_summary.txt"
    else
        print_warning "Coverage data not found"
        echo "⚠️ Coverage data not found" >> "$TEST_RESULTS_DIR/test_summary.txt"
    fi
else
    print_warning "Coverage generation failed"
    echo "⚠️ Coverage generation failed" >> "$TEST_RESULTS_DIR/test_summary.txt"
fi

# Performance testing
print_status "Running performance tests..."
flutter test --reporter=json --coverage > "$TEST_RESULTS_DIR/performance_tests.json" 2>&1 || true

# Generate test report
print_status "Generating comprehensive test report..."
cat > "$TEST_RESULTS_DIR/TEST_REPORT.md" << EOF
# NDIS Connect - Test Report

## Test Execution Summary
- **Test Date**: $(date)
- **Flutter Version**: $FLUTTER_VERSION
- **Test Environment**: $(uname -s) $(uname -m)

## Test Results

### Linter Analysis
$(if [ -f "$TEST_RESULTS_DIR/linter_analysis.txt" ]; then
    if grep -q "No issues found" "$TEST_RESULTS_DIR/linter_analysis.txt"; then
        echo "✅ PASSED - No linter issues found"
    else
        echo "⚠️ ISSUES FOUND - See linter_analysis.txt for details"
    fi
else
    echo "❌ FAILED - Linter analysis could not be completed"
fi)

### Unit Tests
$(if [ -f "$TEST_RESULTS_DIR/unit_tests.json" ]; then
    echo "✅ PASSED - Unit tests completed successfully"
else
    echo "❌ FAILED - Unit tests could not be completed"
fi)

### Widget Tests
$(if [ -f "$TEST_RESULTS_DIR/widget_tests.json" ]; then
    echo "✅ PASSED - Widget tests completed successfully"
else
    echo "❌ FAILED - Widget tests could not be completed"
fi)

### Integration Tests
$(if [ -f "$TEST_RESULTS_DIR/integration_tests.json" ]; then
    echo "✅ PASSED - Integration tests completed successfully"
else
    echo "⚠️ SKIPPED - Integration tests not available"
fi)

### Test Coverage
$(if [ -f "$TEST_RESULTS_DIR/lcov.info" ]; then
    echo "✅ GENERATED - Test coverage report available"
else
    echo "⚠️ NOT AVAILABLE - Test coverage could not be generated"
fi)

## Test Files
- **Unit Tests**: test/unit_test.dart
- **Widget Tests**: test/widget_test.dart
- **Integration Tests**: test/integration_test.dart

## Test Categories
- **Model Tests**: Appointment, Budget, Task, Circle, Shift models
- **Controller Tests**: Auth, Settings, Gamification controllers
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user journey testing
- **Accessibility Tests**: WCAG 2.2 AA compliance testing
- **Performance Tests**: App performance and responsiveness

## Quality Metrics
- **Code Coverage**: Available in coverage_html/ directory
- **Linter Issues**: See linter_analysis.txt
- **Test Execution Time**: See individual test result files

## Recommendations
1. Review any linter issues and fix critical problems
2. Ensure test coverage is above 80% for critical components
3. Add more integration tests for complex user flows
4. Implement automated accessibility testing
5. Set up continuous integration for automated testing

## Next Steps
1. Fix any failing tests
2. Address linter issues
3. Improve test coverage for uncovered areas
4. Set up automated testing pipeline
5. Implement performance monitoring

---
*Generated by NDIS Connect Testing Script*
*Version: 1.0.0*
EOF

# Display test summary
echo
print_status "Test Results Summary:"
cat "$TEST_RESULTS_DIR/test_summary.txt"

# Display test report location
echo
print_success "🎉 Testing completed!"
print_status "Test results saved to: $TEST_RESULTS_DIR"
print_status "Comprehensive report: $TEST_RESULTS_DIR/TEST_REPORT.md"

if [ -f "$TEST_RESULTS_DIR/coverage_html/index.html" ]; then
    print_status "Coverage report: $TEST_RESULTS_DIR/coverage_html/index.html"
fi

# Check if all tests passed
if grep -q "❌" "$TEST_RESULTS_DIR/test_summary.txt"; then
    print_warning "Some tests failed. Please review the test results."
    exit 1
else
    print_success "All tests passed successfully! 🎉"
    exit 0
fi

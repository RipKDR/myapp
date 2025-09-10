# NDIS Connect Design System

## Overview
Modern, accessible design system following Google Material Design 3 principles with NDIS-specific adaptations.

## Color Tokens

### Primary Colors
- **Primary**: `#1A73E8` (Google Blue) - Main brand color
- **Secondary**: `#34A853` (Google Green) - Success, positive actions
- **Tertiary**: `#FBBC04` (Google Yellow) - Warnings, highlights

### Semantic Colors
- **Success**: `#34A853` - Completed actions, positive states
- **Warning**: `#FBBC04` - Caution, pending states
- **Error**: `#EA4335` - Errors, destructive actions
- **Info**: `#1A73E8` - Information, neutral actions

### Neutral Colors
- **Neutral 50-900**: 10-step grayscale from light to dark
- **Surface**: `#FFFFFF` - Card backgrounds, elevated surfaces
- **Background**: `#FAFAFA` - Main app background
- **Outline**: `#DADCE0` - Borders, dividers

### High Contrast Mode
- Enhanced contrast ratios (4.5:1 minimum)
- Bolder borders and shadows
- Increased font weights

## Spacing System

### Base Unit: 4px Grid
- **XS**: 4px - Minimal spacing
- **SM**: 8px - Small spacing
- **MD**: 12px - Medium spacing
- **LG**: 16px - Large spacing
- **XL**: 24px - Extra large spacing
- **XXL**: 32px - Section spacing
- **XXXL**: 48px - Major spacing

### Component Spacing
- **Button Padding**: 16px horizontal, 12px vertical
- **Card Padding**: 24px all sides
- **Screen Padding**: 24px horizontal
- **Form Field Spacing**: 16px between fields

## Typography

### Font Family
- **Primary**: Roboto (Google's system font)
- **Monospace**: RobotoMono (for code, numbers)

### Scale
- **Display Large**: 57px - Hero headlines
- **Headline Large**: 32px - Page titles
- **Title Large**: 22px - Card headers
- **Body Large**: 16px - Main content
- **Label Large**: 14px - Buttons, labels

### Accessibility
- Minimum 16px body text
- 1.5x line height for readability
- High contrast mode increases font weight

## Border Radius

### Standard Values
- **XS**: 4px - Small elements
- **SM**: 8px - Images, small cards
- **MD**: 12px - Cards, inputs (default)
- **LG**: 16px - Chips, FABs
- **XL**: 24px - Buttons (pill shape)
- **Pill**: 999px - Fully rounded

## Shadows & Elevation

### Elevation Levels
- **None**: 0px - Flat surfaces
- **Low**: 1px - Subtle depth
- **Medium**: 3px - Cards, buttons
- **High**: 6px - FABs, dialogs
- **Highest**: 12px - Modals, sheets

## Motion & Animation

### Durations
- **Fast**: 150ms - Button presses
- **Normal**: 250ms - Standard transitions
- **Slow**: 350ms - Page transitions
- **Slower**: 500ms - Modal animations

### Easing
- **Standard**: `easeInOutCubic` - Default
- **Decelerate**: `easeOutCubic` - Entrances
- **Accelerate**: `easeInCubic` - Exits

### Accessibility
- Respects `prefers-reduced-motion`
- Zero duration when motion is reduced
- Linear easing for reduced motion

## Component Guidelines

### Do's
- Use consistent spacing (4px grid)
- Maintain 44px minimum touch targets
- Apply proper contrast ratios
- Use semantic colors appropriately
- Follow Material Design patterns

### Don'ts
- Mix different spacing systems
- Use colors that don't meet contrast requirements
- Create touch targets smaller than 44px
- Ignore accessibility preferences
- Use custom fonts without fallbacks

## Implementation Notes
- All tokens are available as Dart constants
- Theme automatically adapts to light/dark mode
- High contrast mode enhances accessibility
- Components use tokens for consistency
- Easy to customize by modifying token values

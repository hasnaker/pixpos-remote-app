# Implementation Plan: Apple UI Redesign

## Overview

PixPOS Remote uygulamasını Apple 2026 design language'ına uygun şekilde yeniden tasarlıyoruz. Bu plan, design system'den başlayarak tüm UI bileşenlerini ve sayfaları güncelleyecek.

## Tasks

- [x] 1. Design System Core Setup
  - [x] 1.1 Create AppleTheme class with colors, spacing, shadows
    - Create `lib/design_system/apple_theme.dart`
    - Define all color constants (light/dark mode)
    - Define spacing scale (4, 8, 12, 16, 20, 24, 32, 40, 48)
    - Define border radius constants
    - Define shadow presets
    - _Requirements: 1.1, 1.2, 1.3, 4.1, 4.2, 4.3, 4.4_

  - [x] 1.2 Create AppleTypography class
    - Create `lib/design_system/apple_typography.dart`
    - Define all text styles (largeTitle, title1-3, headline, body, etc.)
    - Add Inter font to pubspec.yaml
    - Add JetBrains Mono for monospace
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 1.3 Update main theme configuration
    - Update `lib/common.dart` MyTheme class
    - Apply new color scheme
    - Apply new typography
    - Configure light and dark themes
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Core Components Implementation
  - [x] 2.1 Create GlassContainer component
    - Create `lib/design_system/components/glass_container.dart`
    - Implement BackdropFilter with blur
    - Add semi-transparent background
    - Add subtle border highlight
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 2.2 Create AppleButton component
    - Create `lib/design_system/components/apple_button.dart`
    - Implement filled, outlined, text styles
    - Add press animation (scale 0.97)
    - Add hover state
    - Add loading state
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 2.3 Create AppleCard component
    - Create `lib/design_system/components/apple_card.dart`
    - Implement shadow and border
    - Add hover elevation effect
    - Support dark mode colors
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [x] 2.4 Create AppleTextField component
    - Create `lib/design_system/components/apple_text_field.dart`
    - Implement focus state with accent border
    - Add label and hint support
    - Add validation error state
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 2.5 Create StatusIndicator component
    - Create `lib/design_system/components/status_indicator.dart`
    - Implement color states (green, yellow, red)
    - Add pulse animation
    - _Requirements: 10.1, 10.2, 10.4_

- [x] 3. Dialog and Modal Components
  - [x] 3.1 Create AppleDialog component
    - Create `lib/design_system/components/apple_dialog.dart`
    - Implement blur backdrop
    - Add scale animation
    - Style action buttons
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 3.2 Create AppleToast component
    - Create `lib/design_system/components/apple_toast.dart`
    - Implement slide-in animation
    - Add success/error variants
    - _Requirements: 9.5, 15.3_

- [x] 4. Navigation Components
  - [x] 4.1 Update Sidebar Navigation
    - Update `lib/desktop/widgets/tabbar_widget.dart`
    - Apply new styling with 240px width
    - Add active item highlight
    - Add smooth transitions
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 4.2 Update Tab Bar styling
    - Apply segmented control style
    - Add smooth tab transitions
    - _Requirements: 7.4, 7.5_

- [x] 5. Checkpoint - Core Components Complete
  - Ensure all core components render correctly
  - Test light/dark mode switching
  - Ask user if questions arise

- [x] 6. Desktop Home Page Redesign
  - [x] 6.1 Update left pane layout
    - Apply new spacing and padding
    - Use AppleCard for sections
    - Update typography
    - _Requirements: 4.1, 4.2, 6.1_

  - [x] 6.2 Redesign ID display section
    - Use large monospace font
    - Add accent color highlight
    - Implement copy animation
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 6.3 Redesign password section
    - Apply new text field styling
    - Update button styling
    - _Requirements: 8.1, 5.1_

  - [x] 6.4 Update connection page (right pane)
    - Apply new input field styling
    - Update button styling
    - Add smooth transitions
    - _Requirements: 8.1, 5.1, 7.3_

- [x] 7. Connection List Redesign
  - [x] 7.1 Update peer card design
    - Apply AppleCard styling
    - Update typography
    - Add status indicator
    - _Requirements: 6.1, 6.2, 10.1_

  - [x] 7.2 Update list view
    - Apply 60px minimum height
    - Add separator lines
    - Add hover states
    - _Requirements: 12.1, 12.2, 12.4_

  - [x] 7.3 Implement grid view option
    - Add 2-4 column grid
    - Maintain card styling
    - _Requirements: 12.5_

- [x] 8. Settings Page Redesign
  - [x] 8.1 Update settings layout
    - Apply new section styling
    - Use AppleCard for groups
    - Update typography
    - _Requirements: 6.1, 3.1_

  - [x] 8.2 Update form elements
    - Apply AppleTextField styling
    - Update switch/checkbox styling
    - _Requirements: 8.1, 8.2_

- [x] 9. Toolbar and Action Bar
  - [x] 9.1 Update remote toolbar
    - Apply glassmorphism effect
    - Update icon sizes to 32px
    - Add tooltips with 500ms delay
    - _Requirements: 14.1, 14.3, 14.4_

  - [x] 9.2 Update toolbar animations
    - Add smooth collapse/expand
    - _Requirements: 14.5_

- [x] 10. Loading States
  - [x] 10.1 Update progress indicators
    - Apply accent color
    - Add smooth rotation
    - _Requirements: 13.1, 13.2_

  - [x] 10.2 Implement skeleton loading
    - Create skeleton components
    - Apply to content areas
    - _Requirements: 13.3_

- [x] 11. Checkpoint - Desktop UI Complete
  - Test all desktop pages
  - Verify dark mode consistency
  - Test animations performance
  - Ask user if questions arise

- [x] 12. Mobile UI Updates
  - [x] 12.1 Update mobile home page
    - Apply new styling
    - Ensure 44px touch targets
    - _Requirements: 4.5, 6.1_

  - [x] 12.2 Update mobile navigation
    - Apply new tab bar styling
    - Add smooth transitions
    - _Requirements: 7.4, 7.5_

  - [x] 12.3 Update mobile forms
    - Apply AppleTextField styling
    - Ensure proper keyboard handling
    - _Requirements: 8.1, 8.2_

- [x] 13. Animation Polish
  - [x] 13.1 Add spring animations
    - Implement bouncy effects for key interactions
    - _Requirements: 15.2_

  - [x] 13.2 Verify animation durations
    - Ensure 200-300ms for most transitions
    - _Requirements: 15.4_

- [x] 14. Final Checkpoint
  - Test all pages in light/dark mode
  - Verify responsive behavior
  - Test on different screen sizes
  - Ensure all animations are smooth
  - Ask user for final review

## Notes

- Inter font needs to be added to pubspec.yaml
- JetBrains Mono for monospace text
- All colors should use AppleTheme constants
- All spacing should use AppleTheme spacing scale
- Test on macOS, Windows, and Linux

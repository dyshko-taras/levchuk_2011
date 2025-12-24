# IceLine Tracker - Flutter Visual Style Guide

This document contains the complete design system for the IceLine Tracker Flutter Android app. Use this as a reference for generating UI components and maintaining visual consistency.

## Overview

IceLine Tracker is a hockey game tracking application with a clean, modern design focused on real-time information display and quick interactions.

## Color Palette

### Primary Colors

```dart
// Primary Red - Main brand color, used for CTAs and active states
static const Color primaryRed = Color(0xFFD7092D);

// Live Cyan - Indicates live/final game status
static const Color liveCyan = Color(0xFF09C2D7);

// Scheduled Green - Indicates scheduled games
static const Color scheduledGreen = Color(0xFF2FD709);

// Postponed Orange - Indicates postponed/warning states
static const Color postponedOrange = Color(0xFFD77709);
```

### Neutral Colors

```dart
// Background White
static const Color backgroundWhite = Color(0xFFFFFFFF);

// Surface Gray - Cards and disabled states
static const Color surfaceGray = Color(0xFFCFCFCF);

// Border Gray - Borders and dividers
static const Color borderGray = Color(0xFFB4B4B4);

// Text Black - Primary text
static const Color textBlack = Color(0xFF000000);

// Text Gray - Secondary text (70% opacity)
static const Color textGray = Color(0xB3000000); // rgba(0,0,0,0.7)
```

### Color Usage Guidelines

- **Primary Red (#D7092D)**: Use for primary buttons, active navigation items, brand elements, and important CTAs
- **Live Cyan (#09C2D7)**: Game status badges for live and final games
- **Scheduled Green (#2FD709)**: Game status badges for scheduled games
- **Postponed Orange (#D77709)**: Game status badges for postponed games
- **Background White (#FFFFFF)**: Main app background, card backgrounds
- **Surface Gray (#CFCFCF)**: Secondary surfaces, disabled states, card backgrounds
- **Border Gray (#B4B4B4)**: Borders, inactive toggle backgrounds
- **Text Black (#000000)**: Primary text, headings, labels
- **Text Gray (rgba(0,0,0,0.7))**: Secondary text, descriptions, helper text

## Typography

### Font Family
Primary font: **Open Sans**

Available weights:
- Regular (400)
- SemiBold (600)
- Bold (700)
- ExtraBold (800)
- Italic variants

### Text Styles

```dart
// Display Large - Splash screen title
static const TextStyle displayLarge = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 33,
  fontWeight: FontWeight.w800,
  height: 1.3,
  color: Color(0xFFD7092D),
);

// Heading 1 - Onboarding titles
static const TextStyle heading1 = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 23.1,
  fontWeight: FontWeight.w800,
  color: Color(0xFF000000),
);

// Heading 2 - Section titles
static const TextStyle heading2 = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 18.48,
  fontWeight: FontWeight.w700,
  color: Color(0xFF000000),
);

// Heading 3 - Page titles
static const TextStyle heading3 = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 17.82,
  fontWeight: FontWeight.w600,
  color: Color(0xFF000000),
);

// Body Large - Important descriptions
static const TextStyle bodyLarge = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 16.5,
  fontWeight: FontWeight.w600,
  color: Color(0xB3000000),
);

// Body Regular - Default body text
static const TextStyle bodyRegular = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 15.84,
  fontWeight: FontWeight.w400,
  color: Color(0xFF000000),
);

// Body Semibold - Labels and form fields
static const TextStyle bodySemibold = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 15.84,
  fontWeight: FontWeight.w600,
  color: Color(0xFF000000),
);

// Body Bold - Emphasized text
static const TextStyle bodyBold = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 15.84,
  fontWeight: FontWeight.w700,
  color: Color(0xFF000000),
);

// Caption - Small text
static const TextStyle caption = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 11.88,
  fontWeight: FontWeight.w400,
  color: Color(0xB3000000),
);

// Caption Semibold - Small labels
static const TextStyle captionSemibold = TextStyle(
  fontFamily: 'Open Sans',
  fontSize: 11.88,
  fontWeight: FontWeight.w600,
  color: Color(0xFF000000),
);
```

## Component Specifications

### Primary Button

```dart
Container(
  height: 47.52,
  decoration: BoxDecoration(
    color: Color(0xFFD7092D),
    borderRadius: BorderRadius.circular(7.92),
  ),
  padding: EdgeInsets.symmetric(horizontal: 31.68, vertical: 3.3),
  child: Center(
    child: Text(
      'Button Text',
      style: TextStyle(
        fontFamily: 'Open Sans',
        fontSize: 15.84,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ),
)
```

### Secondary Button (Gradient)

```dart
Container(
  height: 47.52,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFCBCBCB)],
    ),
    borderRadius: BorderRadius.circular(7.92),
    border: Border.all(
      color: Color(0x33000000), // rgba(0,0,0,0.2)
      width: 0.66,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000), // rgba(0,0,0,0.25)
        offset: Offset(0, 1.32),
        blurRadius: 1.32,
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 6.6, vertical: 3.3),
  child: // Button content
)
```

### Toggle Switch

```dart
Container(
  width: 49.17,
  height: 29.77,
  decoration: BoxDecoration(
    color: Color(0xFFB4B4B4), // Inactive track color
    borderRadius: BorderRadius.circular(15.18),
    border: Border.all(
      color: Color(0x1ADADA  DA), // rgba(218,218,218,0.1)
      width: 0.33,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x73000000), // rgba(0,0,0,0.45)
        offset: Offset(-0.33, -0.99),
        blurRadius: 3.3,
        inset: true,
      ),
    ],
  ),
  child: Align(
    alignment: Alignment.centerRight, // or centerLeft when active
    child: Container(
      width: 19.4,
      height: 19.4,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000), // rgba(0,0,0,0.12)
            offset: Offset(0, 0.99),
            blurRadius: 2.31,
          ),
        ],
      ),
    ),
  ),
)
```

### Game Card

```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFCFCFCF),
    borderRadius: BorderRadius.circular(7.92),
    border: Border.all(
      color: Color(0x33000000), // rgba(0,0,0,0.2)
      width: 0.66,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000), // rgba(0,0,0,0.25)
        offset: Offset(0, 1.32),
        blurRadius: 1.32,
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 6.6, vertical: 9.9),
  child: // Card content
)
```

### Status Badge

```dart
// Live/Final status
Container(
  decoration: BoxDecoration(
    color: Color(0xFFD7092D), // Live
    // color: Color(0xFF09C2D7), // Final
    // color: Color(0xFF2FD709), // Scheduled
    // color: Color(0xFFD77709), // Postponed
    borderRadius: BorderRadius.circular(7.92),
    border: Border.all(
      color: Color(0x33000000),
      width: 0.66,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        offset: Offset(0, 1.32),
        blurRadius: 1.32,
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 13.2, vertical: 3.3),
  child: Text(
    'Live',
    style: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 11.88,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
)
```

### Segmented Control (Date Picker)

```dart
Container(
  height: 47.52,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFCBCBCB)],
    ),
    borderRadius: BorderRadius.circular(7.92),
    border: Border.all(color: Color(0x33000000), width: 0.66),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        offset: Offset(0, 1.32),
        blurRadius: 1.32,
      ),
    ],
  ),
  child: Row(
    children: [
      // Active segment
      Container(
        height: 47.52,
        width: 103.29,
        decoration: BoxDecoration(
          color: Color(0xFFD7092D),
          borderRadius: BorderRadius.circular(7.92),
        ),
        child: Center(child: Text('Today')),
      ),
      // Inactive segments...
    ],
  ),
)
```

## Spacing Scale

```dart
// Spacing constants
static const double spaceXS = 3.3;
static const double spaceS = 6.6;
static const double spaceM = 9.9;
static const double spaceL = 13.2;
static const double spaceXL = 16.5;
static const double space2XL = 31.68;
```

## Border Radius

```dart
// Border radius constants
static const double radiusSmall = 6.6;
static const double radiusMedium = 7.92;
static const double radiusLarge = 15.18;
static const double radiusCircle = 999;
```

## Shadows

```dart
// Button/Card shadow
static const List<BoxShadow> shadowDefault = [
  BoxShadow(
    color: Color(0x40000000), // rgba(0,0,0,0.25)
    offset: Offset(0, 1.32),
    blurRadius: 1.32,
  ),
];

// Toggle knob shadow
static const List<BoxShadow> shadowKnob = [
  BoxShadow(
    color: Color(0x1F000000), // rgba(0,0,0,0.12)
    offset: Offset(0, 0.99),
    blurRadius: 2.31,
  ),
];

// Inset shadow for toggles
static const List<BoxShadow> shadowInset = [
  BoxShadow(
    color: Color(0x73000000), // rgba(0,0,0,0.45)
    offset: Offset(-0.33, -0.99),
    blurRadius: 3.3,
    // Note: Use CustomPainter for true inset shadows in Flutter
  ),
];
```

## Layout Specifications

### Screen Dimensions
- Mobile screen width: 356.4px
- Content width: 323.4px
- Side padding: 16.5px
- Safe area top: 23.76px

### Icon Sizes
- Small: 23.76px
- Medium: 29.77px
- Large: 33px

## Gradients

```dart
// Background gradient (splash/onboarding)
static const LinearGradient backgroundGradient = LinearGradient(
  begin: Alignment(0, 0.09615),
  end: Alignment(0, 0.66732),
  stops: [0.09615, 0.59326, 0.66732],
  colors: [
    Color(0x00000000), // Transparent
    Color(0xFFFFFFFF), // White
    Color(0xFFFFFFFF), // White
  ],
);

// Button gradient
static const LinearGradient buttonGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFFFFF), Color(0xFFCBCBCB)],
);
```
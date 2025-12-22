# Shared UI Components

## Purpose

Shared UI components establish a consistent visual language across your game. They provide reusable, themeable widgets that maintain design consistency while reducing code duplication.

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
```

No additional packages required - pure Flutter widgets.

## Core Components

### 1. GameLabel - Styled Text Display

**Purpose**: Display text with outline and shadow effects for readability over game backgrounds.

**Architecture**:
```dart
enum GameLabelSize { small, medium, large, title }

class GameLabel extends StatelessWidget {
  final String text;
  final GameLabelSize size;
  final Color color;
  final TextAlign textAlign;

  // Size-specific properties:
  // - fontSize: 18, 24, 36, 48
  // - outlineWidth: 1.5, 2.0, 2.5, 3.0
  // - shadowBlur: 4, 6, 8, 10
}
```

**Key Features**:
- Enum-based size system with computed properties
- Layered text rendering (outline + shadow + fill)
- Custom font support via theme
- High contrast for game backgrounds

**Setup Checklist**:
- [ ] Define GameLabelSize enum
- [ ] Implement size-to-property mapping
- [ ] Add custom font to assets and theme
- [ ] Create text shadow/outline rendering logic
- [ ] Set default colors from theme

**Customization**:
- Add more size variants (extraSmall, extraLarge)
- Support gradient text fills
- Add animation parameter for pulsing/glowing effects
- Include icon support for inline images

**Usage Pattern**:
```dart
GameLabel(
  text: 'Score: 1000',
  size: GameLabelSize.medium,
  color: AppColors.neonCyan,
)
```

---

### 2. GameButton - Interactive Button with Animations

**Purpose**: Provide tactile feedback with scale animations and audio on tap.

**Architecture**:
```dart
// Role-based button styling
enum GameButtonStyle {
  primary,      // Main positive actions (PLAY, RESUME, CONFIRM)
  secondary,    // Cancel/back actions (CANCEL, STAY, MAIN MENU)
  destructive,  // Warning actions (DELETE, RESET, QUIT)
  neutral,      // Utility actions (DEBUG, INFO)
}

// Width steps for automatic button sizing
enum ButtonWidthStep {
  small(200),   // Short labels (e.g., "Play", "Settings")
  medium(300),  // Medium labels (e.g., "Complete Puzzle")
  large(400);   // Long labels or multiple words

  static double getSteppedWidth({
    required BuildContext context,
    required String? label,
    required IconData? icon,
  }); // Measures actual content width using TextPainter for accurate sizing
  // Note: Adjust step values (200/300/400) to match your project's UI scale
}

class GameButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final GameButtonStyle style;      // Role-based styling (primary, secondary, etc.)
  final List<Color>? gradientColors; // Optional: Override style colors
  final Color? borderColor;          // Optional: Override style border
  final Color? iconColor;            // Optional: Override style icon color
  final double? minWidth;  // Override automatic width calculation
  final EdgeInsetsGeometry? padding;
  final bool isCircular; // Circle vs rounded rectangle
  final bool enabled;
  final double? elevation;

  // Uses AnimationController for scale animation
  // 100ms easeInOut curve, scales to 0.95 on tap
  // Rectangular buttons use automatic stepped width (configurable steps)
  // Styling automatically determined by GameButtonStyle enum (can be overridden)
}
```

**Key Features**:
- Scale-down animation on tap (0.95x)
- Automatic button sound playback via ServiceLocator
- Support for icon-only or icon+label layouts
- Circular or rectangular shapes
- Dispose-safe animation controllers
- **Stepped width sizing** for consistent button dimensions

**Width Sizing System**:

Rectangular buttons automatically size themselves using a stepped width approach to ensure visual consistency across the app. This prevents buttons from having arbitrary widths and creates a cohesive design language.

**Width Steps** (configurable to your needs):
- **Small (e.g., 200px)**: Short labels like "Play", "Start", "Settings", "Resume", "Quit"
- **Medium (e.g., 300px)**: Medium labels like "Complete Puzzle"
- **Large (e.g., 400px)**: Long labels or multiple words

*Note: Choose step values that work for your game's UI scale and typical button content.*

**Automatic Width Calculation**:
The `ButtonWidthStep.getSteppedWidth()` method measures actual content width using Flutter's TextPainter for pixel-perfect accuracy:

1. **Base padding**: Your horizontal padding (e.g., 64px = 32px per side)
2. **Icon width**: Your icon size (e.g., 24px, if icon is present)
3. **Gap**: Spacing between icon and label (e.g., 12px)
4. **Label measurement**: Uses `TextPainter` to measure the exact width of text rendered with:
   - Font: Match your button's TextStyle (family, weight)
   - Size: Match your button's text size (e.g., 18px)
   - Includes `MediaQuery.textScalerOf(context)` for accessibility support

**Implementation Note**: The actual padding, icon size, gap, and text style values should match your GameButton's implementation. Measure content using the same TextStyle that will be rendered in the button to ensure accuracy.

**Why TextPainter?**
- Accurate for custom fonts (no character estimation needed)
- Accounts for font kerning and letter spacing
- Respects user text scaling preferences (accessibility)
- Eliminates overflow and unnecessary width jumps

The algorithm measures the total content width and selects the next step up (from your configured steps) that can accommodate it.

**Manual Width Override**:
You can override the automatic sizing by providing a `minWidth` parameter:
```dart
GameButton.rectangular(
  label: 'Custom Width',
  minWidth: 250,  // Overrides automatic sizing
  onPressed: () {},
)
```

**Best Practices**:
- Let buttons use automatic sizing unless you have a specific layout requirement
- Buttons with similar content length will automatically get the same width
- Use manual width only when you need exact alignment with other UI elements

**Using Buttons in Dialogs**:

When using `GameButton` in `GameDialog.actions`, follow these important guidelines:

⚠️ **Critical Warning:**
DO NOT wrap `GameButton` widgets in `Expanded` or `Flexible` when passing to `GameDialog.actions`. GameDialog uses a `Row` layout that expects fixed-width children. Wrapping buttons in `Expanded`/`Flexible` will cause `RenderFlex` overflow errors.

**Why This Matters:**
- GameDialog constrains its width to `(screenWidth * 0.85).clamp(280.0, 500.0)`
- GameButton uses fixed stepped widths (200/300/400px)
- Row with `MainAxisAlignment.spaceEvenly` distributes fixed-width buttons
- Expanded/Flexible tries to force buttons to fill available space, conflicting with fixed widths
- Result: RenderFlex overflow errors and broken layouts

**Correct Usage:**
```dart
actions: [
  GameButton.rectangular(label: 'Cancel', onPressed: () {}),
  GameButton.rectangular(label: 'Confirm', onPressed: () {}),
]
```

**Incorrect Usage:**
```dart
actions: [
  Expanded(child: GameButton.rectangular(...)),  // ❌ CAUSES OVERFLOW
  Flexible(child: GameButton.rectangular(...)),  // ❌ CAUSES OVERFLOW
]
```

See **GameDialog** documentation (Section 4) for complete examples and action button patterns.

**Setup Checklist**:
- [ ] Define GameButtonStyle enum with role-based values (primary, secondary, destructive, neutral)
- [ ] Create StatefulWidget with AnimationController
- [ ] Implement tap gesture detection
- [ ] Add scale transform wrapper
- [ ] Implement style-to-color mapping methods
- [ ] Integrate with AudioService for button sounds
- [ ] Support both circular and rectangular variants
- [ ] Handle proper disposal of animation controller

**Customization**:
- Add haptic feedback on tap
- Support disabled state with opacity
- Add loading state with spinner
- Support gradient backgrounds
- Add badge/notification indicator overlay

**Integration Points**:
- **AudioService** - Plays button sound on tap
- **Theme** - Colors from AppColors
- **Navigation** - Often triggers screen transitions

**Common Patterns**:
```dart
// Primary action button (default style)
GameButton(
  label: 'Play',
  icon: Icons.play_arrow,
  onPressed: () => _startGame(),
  style: GameButtonStyle.primary,  // Gold/primary theme color
)

// Secondary action button (alternative/cancel actions)
GameButton(
  label: 'Cancel',
  icon: Icons.close,
  onPressed: () => Navigator.pop(context),
  style: GameButtonStyle.secondary,  // Chrome/silver theme color
)

// Destructive action button (warning/delete actions)
GameButton(
  label: 'Delete',
  icon: Icons.delete_forever,
  onPressed: () => _deleteData(),
  style: GameButtonStyle.destructive,  // Red warning color
)

// Neutral action button (utility/debug actions)
GameButton(
  label: 'Debug',
  icon: Icons.bug_report,
  onPressed: () => _openDebug(),
  style: GameButtonStyle.neutral,  // Steel/muted theme color
)

// Override automatic styling with custom colors
GameButton(
  label: 'Special',
  icon: Icons.star,
  onPressed: () => _special(),
  style: GameButtonStyle.primary,
  borderColor: AppColors.customColor,  // Override border
  iconColor: AppColors.customColor,    // Override icon
)

// Circular icon-only button
GameButton(
  icon: Icons.pause,
  onPressed: () => _pauseGame(),
  circular: true,
  style: GameButtonStyle.secondary,
)

// Button with manual width override
GameButton(
  label: 'Settings',
  icon: Icons.settings,
  minWidth: 250,  // Override automatic sizing
  onPressed: () => _navigateToSettings(),
  style: GameButtonStyle.secondary,
)
```

---

### 3. GameIconButton - Compact Icon Button

**Purpose**: Small, circular buttons for navigation and controls (back buttons, HUD controls).

**Architecture**:
```dart
class GameIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size; // Button diameter
}
```

**Key Features**:
- Fixed circular shape
- Simpler than GameButton (no animation by default)
- Consistent sizing across app
- Transparent backgrounds with borders

**Setup Checklist**:
- [ ] Create StatelessWidget (or StatefulWidget for animations)
- [ ] Add IconButton or custom GestureDetector
- [ ] Apply circular container decoration
- [ ] Integrate button sound playback
- [ ] Set default size and colors

**Usage Pattern**:
```dart
GameIconButton(
  icon: Icons.arrow_back,
  onPressed: () => Navigator.pop(context),
  backgroundColor: Colors.black54,
)
```

---

### 4. GameDialog - Animated Modal Container

**Purpose**: Unified dialog presentation with consistent animations and styling.

**Architecture**:
```dart
class GameDialog extends StatefulWidget {
  final String? title;
  final Widget child;
  final double width;
  final bool dismissible;

  // Animation sequence:
  // 1. Fade in overlay (300ms)
  // 2. Elastic bounce scale (600ms, ElasticOut curve)

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool dismissible = true,
  })
}
```

**Key Features**:
- Static `.show()` method for easy presentation
- Elastic bounce-in animation
- Fade-in overlay
- Optional title with decorative separator
- Configurable dismissibility
- Reverse animation on dismiss

**Setup Checklist**:
- [ ] Create StatefulWidget with AnimationController
- [ ] Implement fade and scale animations (parallel)
- [ ] Add showDialog wrapper in static method
- [ ] Create title section with optional separator
- [ ] Handle WillPopScope for dismissibility
- [ ] Implement proper animation disposal

**Customization**:
- Add background blur effect
- Support different animation curves (bounce, spring, etc.)
- Add swipe-to-dismiss gesture
- Include close button option
- Support full-screen variant

**Animation Details**:
```
Fade:  0 → 1 (0-300ms, easeIn)
Scale: 0 → 1 (0-600ms, ElasticOut)
```

**Usage Pattern**:
```dart
await GameDialog.show(
  context: context,
  title: 'Game Over',
  child: GameOverContent(),
  dismissible: false,
);
```

**Action Buttons**:

GameDialog supports an optional `actions` parameter for displaying action buttons (like Cancel, Confirm, etc.) at the bottom of the dialog.

**Critical Requirements:**
- Pass `GameButton` widgets directly WITHOUT wrapping in `Expanded` or `Flexible`
- Buttons automatically use stepped width sizing (from your configured steps)
- Multiple buttons are spaced evenly using `MainAxisAlignment.spaceEvenly`
- GameDialog handles layout and spacing automatically
- Use role-based styling (GameButtonStyle) for semantic clarity

**Why No Expanded/Flexible:**
GameDialog uses a `Row` with fixed horizontal padding. Each `GameButton` has a fixed stepped width (from your configured steps). Wrapping buttons in `Expanded`/`Flexible` causes `RenderFlex` overflow errors because Flutter tries to expand fixed-width widgets beyond the available space.

**Standardized Button Styling:**
For consistency, use role-based styles:
- **Cancel/Back actions**: `GameButtonStyle.secondary` with `Icons.close`
- **Confirm/Accept actions**: `GameButtonStyle.primary`
- **Delete/Reset actions**: `GameButtonStyle.destructive` with `Icons.delete_forever`

**Examples:**

Single Action Button:
```dart
GameDialog.show(
  context: context,
  title: 'Achievement Unlocked',
  content: AchievementContent(),
  actions: [
    GameButton(
      label: 'Awesome!',
      icon: Icons.star,
      style: GameButtonStyle.primary,
      onPressed: () => Navigator.pop(context),
    ),
  ],
)
```

Two Action Buttons (Cancel + Confirm):
```dart
GameDialog.show(
  context: context,
  title: 'Reset Progress?',
  content: WarningMessage(),
  actions: [
    // Cancel button with secondary style
    GameButton(
      label: 'Cancel',
      icon: Icons.close,
      style: GameButtonStyle.secondary,
      onPressed: () => Navigator.pop(context),
    ),
    // Confirm button with destructive style
    GameButton(
      label: 'Confirm',
      icon: Icons.delete_forever,
      style: GameButtonStyle.destructive,
      onPressed: () => _confirmAction(),
    ),
  ],
)
```

Multiple Action Buttons:
```dart
GameDialog.show(
  context: context,
  title: 'Choose Difficulty',
  content: DifficultyExplanation(),
  actions: [
    GameButton(label: 'Easy', style: GameButtonStyle.primary, onPressed: () => _setEasy()),
    GameButton(label: 'Normal', style: GameButtonStyle.primary, onPressed: () => _setNormal()),
    GameButton(label: 'Hard', style: GameButtonStyle.primary, onPressed: () => _setHard()),
  ],
)
```

**Common Mistakes:**

❌ WRONG - Wrapping in Expanded (causes overflow):
```dart
actions: [
  Expanded(  // DON'T DO THIS
    child: GameButton(
      label: 'Cancel',
      style: GameButtonStyle.secondary,
      onPressed: () {},
    ),
  ),
]
```

✓ CORRECT - Direct GameButton with role-based style:
```dart
actions: [
  GameButton(
    label: 'Cancel',
    style: GameButtonStyle.secondary,
    onPressed: () {},
  ),
]
```

**Troubleshooting Overflow Issues:**

If you see `RenderFlex overflow` errors:
1. Check if buttons are wrapped in `Expanded`/`Flexible` - remove these wrappers
2. Verify button labels aren't excessively long (>15 characters may cause issues)
3. Consider using shorter labels or manual `minWidth` override
4. Test on smaller screen sizes (280-350px dialog width)

---

### 5. ScreenHeader - Standard Page Header

**Purpose**: Consistent header across all secondary screens with back navigation.

**Architecture**:
```dart
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed; // Optional custom back action

  // Layout: [Back Button] [Title] [Spacer]
}
```

**Key Features**:
- Left-aligned back button
- Centered or left-aligned title
- Consistent height and padding
- Optional custom back action

**Setup Checklist**:
- [ ] Create horizontal Row layout
- [ ] Add GameIconButton for back navigation
- [ ] Add GameLabel for title
- [ ] Set consistent height constraint
- [ ] Handle default Navigator.pop

**Usage Pattern**:
```dart
Column(
  children: [
    ScreenHeader(title: 'Achievements'),
    Expanded(child: AchievementList()),
  ],
)
```

---

### 6. GameBackground - Consistent Backgrounds

**Purpose**: Provide uniform background styling across screens.

**Architecture**:
```dart
class GameBackground extends StatelessWidget {
  final Widget child;
  final String? imageAsset;
  final Color? backgroundColor;
  final BoxFit fit;

  // Renders: Background (image/color) + Overlay gradient + Child
}
```

**Key Features**:
- Support image or solid color backgrounds
- Optional gradient overlay for depth
- Consistent BoxFit handling
- Centers child content

**Setup Checklist**:
- [ ] Create Stack-based layout
- [ ] Add background layer (DecorationImage or Container)
- [ ] Add optional gradient overlay
- [ ] Position child content
- [ ] Handle asset loading errors

**Customization**:
- Add parallax scrolling effect
- Support animated background transitions
- Include blur option
- Add particle overlay system

---

### 7. FadingScrollView - Scrollable Content with Edge Fading

**Purpose**: Wrap any scrollable widget to automatically apply smooth transparency fade effects at top and bottom edges, creating seamless blending with backgrounds.

**Architecture**:
```dart
class FadingScrollView extends StatelessWidget {
  final Widget child;           // Any scrollable widget
  final double fadePercentage;  // 0.0 to 0.5, default 0.05 (5%)
  final EdgeInsetsGeometry? padding;

  // Uses ShaderMask with BlendMode.dstIn for true transparency
  // Gradient: transparent → black → black → transparent
}
```

**Key Features**:
- True transparency masking (not color overlays)
- Works with any scrollable widget (ListView, GridView, SingleChildScrollView)
- Configurable fade distance (percentage of content height)
- Optional padding parameter
- No performance overhead - single render pass
- No gesture blocking - content remains fully interactive

**Technical Implementation**:
- Uses `ShaderMask` with `BlendMode.dstIn`
- Gradient uses opacity-only masking (black = visible, transparent = hidden)
- Top and bottom fade zones calculated from `fadePercentage`
- Default 5% fade creates smooth transitions without noticeable content loss

**Setup Checklist**:
- [ ] Create StatelessWidget accepting child and optional parameters
- [ ] Calculate gradient stops from fadePercentage
- [ ] Implement ShaderMask with LinearGradient
- [ ] Use BlendMode.dstIn for transparency masking
- [ ] Apply optional padding wrapper
- [ ] Add parameter validation (fadePercentage must be 0.0-0.5)

**When to Use**:
- ✅ **Any scrollable content** - ListView, GridView, SingleChildScrollView
- ✅ **Content over backgrounds** - Puzzle lists, settings screens, dialogs
- ✅ **Long scrollable areas** - Story text, achievement lists, inventory
- ✅ **Between fixed headers/footers** - Creates soft visual padding
- ❌ **Non-scrollable content** - No benefit, adds unnecessary wrapper

**Customization**:
- Adjust fadePercentage for longer/shorter fades
- Add asymmetric fading (different percentages for top/bottom)
- Support horizontal scrolling with left/right fades
- Add dynamic fade based on scroll position
- Include fade color parameter for special effects

**Usage Patterns**:
```dart
// Basic usage - wraps ListView
FadingScrollView(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(...),
  ),
)

// With padding - common pattern for horizontal margins
FadingScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: GridView.count(
    crossAxisCount: 3,
    children: puzzleCards,
  ),
)

// Custom fade distance - 8% fade zones
FadingScrollView(
  fadePercentage: 0.08,
  child: SingleChildScrollView(
    child: LongStoryText(),
  ),
)

// In dialogs - fade dialog content
GameDialog(
  title: 'Instructions',
  child: FadingScrollView(
    child: SingleChildScrollView(
      child: InstructionsContent(),
    ),
  ),
)
```

**Integration Points**:
- **All scrollable screens** - Settings, puzzle selection, achievements
- **GameDialog** - Scrollable dialog content
- **Story/Tutorial screens** - Long text content
- **Inventory/Collection screens** - Scrollable item grids

**Best Practices**:
1. **Use everywhere** - Apply to all scrollable content for consistency
2. **Set early** - Add during initial widget creation, not as afterthought
3. **Keep defaults** - 5% fade works well for most cases
4. **Test on device** - Verify fade looks natural on actual screen sizes
5. **Combine with padding** - Use padding parameter instead of extra wrappers

**Why This Approach**:
- **True transparency** - Content actually becomes transparent, revealing background
- **Not color overlays** - Avoids tinting or color contamination
- **Performance** - Single shader pass, no additional render layers
- **Composable** - Works as drop-in replacement for any scrollable widget
- **Consistent UX** - Same fade effect across entire app

---

### 8. StatIndicator - Non-Interactive Stat Display

**Purpose**: Display read-only game statistics (coins, speed, distance, score) with styling that is clearly distinct from interactive buttons.

**Critical Design Principle**: StatIndicator must look visually different from buttons to prevent user confusion. Use flat styling without 3D effects, shadows, or button-like gradients.

**Architecture**:
```dart
class StatIndicator extends StatelessWidget {
  final String value;           // Required: The stat value to display
  final String? label;          // Optional: Label text (e.g., "Score")
  final IconData? icon;         // Optional: Icon before value
  final String? imagePath;      // Optional: Image before value (alternative to icon)
  final double iconSize;        // Size for icon/image (default: 20)
  final Color iconColor;        // Icon color (default: white)
  final Color? backgroundColor; // Background (default: dark transparent)
  final Color? borderColor;     // Border (default: subtle semi-transparent)
  final Color? textColor;       // Text color (default: white)

  // Layout: [Icon/Image] [Label: ] [Value]
  // Style: Flat, semi-transparent, NO shadows or 3D effects
}
```

**Key Features**:
- **StatelessWidget** - No animations (unlike buttons)
- **Flat styling** - Semi-transparent backgrounds, thin borders (2px), no shadows
- **Clear non-interactive appearance** - Distinct from buttons
- Support icon OR image display
- Optional label + value layout
- Minimal padding for compact display
- Text shadows for readability over game backgrounds
- Customizable colors for project-specific themes

**Visual Distinction from Buttons**:
- **Background**: Dark, highly transparent (50% opacity) vs solid/gradient button backgrounds
- **Border**: Thin (2px), semi-transparent (40% opacity) vs thick (3-4px) opaque button borders
- **Shape**: Rectangular/pill-shaped vs often circular buttons
- **Effects**: No shadows, no 3D embossing, no gradients vs button depth effects
- **Interaction**: No hover, press, or animation states

**Setup Checklist**:
- [ ] Create StatelessWidget with required value parameter
- [ ] Add optional icon/image slot (mutually exclusive)
- [ ] Add optional label parameter
- [ ] Implement Container with rounded corners
- [ ] Apply semi-transparent dark background (e.g., black 50% opacity)
- [ ] Add thin, subtle border (e.g., white 40% opacity, 2px width)
- [ ] Set minimal padding (e.g., 12px horizontal, 6px vertical)
- [ ] Add text shadows for readability
- [ ] Support color customization via optional parameters

**Customization**:
- Override backgroundColor for project-specific themes
- Adjust borderColor and width for different visual styles
- Add iconColor parameter for themed icons
- Support different border radius values
- Add optional badge/notification overlay

**Usage Patterns**:
```dart
// In-game HUD - coin display
StatIndicator(
  value: '250',
  imagePath: 'assets/images/ui/coin.png',
  iconSize: 24,
)

// Speed display with icon
StatIndicator(
  value: '120 km/h',
  icon: Icons.speed,
  iconSize: 20,
)

// Distance with label
StatIndicator(
  label: 'Distance',
  value: '1.5 km',
  icon: Icons.map,
)

// In ScreenHeader trailing position
ScreenHeader(
  title: 'Shop',
  trailing: StatIndicator(
    value: '${playerCoins}',
    imagePath: 'assets/images/ui/coin.png',
  ),
)

// Custom themed colors
StatIndicator(
  value: '99',
  icon: Icons.star,
  backgroundColor: Colors.purple.withOpacity(0.3),
  borderColor: Colors.purpleAccent.withOpacity(0.5),
)
```

**Integration Points**:
- **GameScreen HUD** - Display coins, speed, distance, score during gameplay
- **ScreenHeader** - Show currency balance in trailing position
- **Shop/Garage screens** - Display purchasable currency
- **Any screen** - Non-interactive stat displays

---

## Additional Specialized Dialogs

### PauseDialog
- Extends GameDialog
- Shows "Resume" and "Quit" options
- Optional settings access

### GameOverDialog
- Extends GameDialog
- Displays final score, level
- "New Best!" badge for high scores
- Replay and menu buttons

### TutorialDialog
- Extends GameDialog
- Shows on first launch only
- Explains controls and objectives
- Sets flag in settings to not show again

### ConfirmationDialog (e.g., ResetDataDialog)
- Extends GameDialog
- Shows warning message
- "Cancel" and "Confirm" buttons
- Different button colors for emphasis

---

## Component Hierarchy

```
Base Components (used everywhere):
├── GameLabel (text rendering)
├── GameButton (primary interactions)
└── GameIconButton (secondary actions)

Container Components (wrap content):
├── GameDialog (modal overlays)
├── GameBackground (full-screen backgrounds)
├── FadingScrollView (scrollable content wrapper)
└── ScreenHeader (page headers)

Specialized Components (specific use cases):
├── StatIndicator (non-interactive stat displays)
├── PauseDialog (game pause state)
├── GameOverDialog (game end state)
├── TutorialDialog (first-launch help)
└── ConfirmationDialog (destructive actions)
```

---

## Styling Consistency

All components should:
1. **Use theme colors** - Reference AppColors, never hardcode
2. **Follow size system** - Consistent padding, margins, border radius
3. **Support accessibility** - Minimum touch targets (48x48)
4. **Handle states** - Disabled, loading, error states
5. **Dispose properly** - Clean up controllers and listeners
6. **Play audio feedback** - Button taps, important events
7. **Respect theme mode** - Work in light/dark themes

## Implementation Order

1. **GameLabel** - Foundation for all text
2. **GameButton** - Primary interaction element
3. **GameIconButton** - Navigation and controls
4. **GameDialog** - Container for all modals
5. **ScreenHeader** - Standard page layout
6. **GameBackground** - Screen backgrounds
7. **FadingScrollView** - Scrollable content wrapper (use from start!)
8. **StatIndicator** - Non-interactive stat displays
9. **Specialized Dialogs** - Build on GameDialog

---

## Integration with Other Systems

| Component | Integrates With | Purpose |
|-----------|-----------------|---------|
| GameButton | AudioService | Button sound playback |
| GameDialog | Navigation | Modal presentation |
| ScreenHeader | Navigation | Back button functionality |
| FadingScrollView | All scrollable widgets | Consistent fade effects |
| StatIndicator | Various screens | Non-interactive stat display |
| GameBackground | BackgroundManager | Dynamic background switching |
| Video Screens | AudioService | Video/music coordination |

---

## Testing Recommendations

1. **Visual consistency** - Create a demo screen showing all components
2. **Animation testing** - Verify smooth 60fps animations
3. **Responsiveness** - Test on different screen sizes
4. **Accessibility** - Test with TalkBack/VoiceOver
5. **Theme switching** - Verify appearance in light/dark modes
6. **Edge cases** - Long text, missing assets, null values

---

## Common Pitfalls & Solutions

### 1. RenderFlex Overflow with Dialog Buttons

**Problem:**
`RenderFlex` overflow errors when displaying `GameDialog` with action buttons.

**Symptoms:**
```
RenderFlex overflowed by X pixels on the right.
The relevant error-causing widget was: Row
```

**Cause:**
Wrapping `GameButton` widgets in `Expanded` or `Flexible` within `GameDialog.actions`.

**Solution:**
Pass `GameButton` widgets directly without any wrapping:

```dart
// ❌ WRONG - Causes overflow
actions: [
  Expanded(child: GameButton.rectangular(...)),
  Flexible(child: GameButton.rectangular(...)),
]

// ✓ CORRECT - No wrapper
actions: [
  GameButton.rectangular(...),
  GameButton.rectangular(...),
]
```

**Why It Happens:**
- GameDialog uses a `Row` with fixed horizontal padding
- GameButton has fixed stepped widths (from your configured steps) via automatic sizing
- When wrapped in `Expanded`/`Flexible`, Flutter tries to expand the fixed-width button
- The expanded size exceeds dialog's available width constraints
- Result: RenderFlex reports overflow and clips content

**Prevention:**
- Always pass `GameButton` widgets directly to `actions` parameter
- Let GameButton's automatic width system handle sizing
- GameDialog's `Row` layout will distribute buttons evenly with `MainAxisAlignment.spaceEvenly`
- Test on smaller screen sizes (280px dialog width) to catch issues early
- Keep button labels concise (under 15 characters recommended)

**If You Must Control Layout:**
Instead of using `Expanded`, override button widths explicitly:
```dart
actions: [
  GameButton.rectangular(
    label: 'Cancel',
    minWidth: 150,  // Explicit width override
    onPressed: () {},
  ),
]
```

### 2. Button Width Conflicts in Custom Layouts

**Problem:**
Buttons appear too wide or cause overflow in custom `Row`/`Column` layouts outside of dialogs.

**Cause:**
GameButton's automatic stepped width (200/300/400px) doesn't fit your custom layout constraints.

**Solution:**
Use manual width override with `minWidth` parameter:

```dart
Row(
  children: [
    GameButton.rectangular(
      label: 'Settings',
      minWidth: 150,  // Override automatic sizing
      onPressed: () {},
    ),
    SizedBox(width: 8),
    GameButton.rectangular(
      label: 'Help',
      minWidth: 150,  // Match other button width
      onPressed: () {},
    ),
  ],
)
```

**When to Override Automatic Width:**
- Custom layouts with specific space constraints
- Matching button widths to other UI elements (cards, panels, etc.)
- Creating compact button groups in limited space
- Side-by-side buttons in narrow areas (like bottom sheets)
- Unusual screen layouts that don't work with standard steps

**When NOT to Override:**
- Standard `GameDialog` actions (let automatic sizing work)
- Full-screen button layouts (steps provide consistency)
- Menu buttons (steps create visual rhythm)
- Any layout where you want consistent, predictable widths

**Best Practice:**
Start with automatic width. Only add `minWidth` override if you encounter specific layout issues.

### 3. Inconsistent Button Styling

**Problem:**
Buttons have inconsistent colors, icons, or styles across different contexts, making it unclear what actions they perform.

**Solution:**
Always use role-based styling with GameButtonStyle:

```dart
// Cancel/secondary actions
GameButton(
  label: 'Cancel',
  icon: Icons.close,
  style: GameButtonStyle.secondary,
  onPressed: () {},
)

// Primary/confirm actions
GameButton(
  label: 'Confirm',
  icon: Icons.check,
  style: GameButtonStyle.primary,
  onPressed: () {},
)

// Destructive/warning actions
GameButton(
  label: 'Delete',
  icon: Icons.delete_forever,
  style: GameButtonStyle.destructive,
  onPressed: () {},
)
```

**Why Consistency Matters:**
- Users recognize actions by their role-based styling
- Semantic naming makes code intent clear
- Consistent styling reduces cognitive load
- Creates professional, polished UX
- Theme-agnostic (colors can change without updating button code)
- Easy to maintain across projects

---

## Next Steps

After implementing shared UI components:
- Configure **Theme & Styling** (08_Theme_And_Styling.md) for consistent colors
- Set up **Navigation System** (02_Navigation_System.md) to use these components
- Integrate **Audio Service** (03_Audio_System.md) for button sounds and video coordination

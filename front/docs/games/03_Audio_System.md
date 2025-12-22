# Audio System

## Purpose

A professional audio system manages background music and sound effects (SFX) with respect to user preferences, app lifecycle events, and platform constraints. It ensures audio doesn't play when the app is in the background and provides clean multichannel support for simultaneous sound effects.

## Dependencies

```yaml
dependencies:
  flame_audio: ^2.11.11  # Built on audioplayers, provides AudioPool
```

`flame_audio` provides:
- **Background music** management with looping
- **AudioPool** for multichannel SFX (simultaneous sounds)
- **Volume control** for music and effects
- **Preloading** for performance

---

## Architecture

### AudioService Class

**Purpose**: Centralized audio management with lifecycle awareness

**Architecture**:
```dart
class AudioService {
  // State
  bool _isMusicPlaying = false;
  bool _appPaused = false; // Critical for background handling

  // Settings integration
  final SettingsService _settingsService;

  // Methods:
  // - Background Music
  Future<void> initialize()
  Future<void> playBackgroundMusic()
  Future<void> pauseBackgroundMusic()
  Future<void> resumeBackgroundMusic()
  Future<void> stopBackgroundMusic()

  // - Sound Effects
  Future<void> playSound(String filename, {double volume = 1.0})
  Future<void> playButtonSound()
  Future<void> playCrystalSound()
  Future<void> playGameOverSound()

  // - Lifecycle
  void onAppPaused()
  void onAppResumed()
}
```

**Key Features**:
- Respects user settings (music on/off, SFX on/off)
- Prevents audio in background via `_appPaused` flag
- Multichannel SFX via AudioPool
- Volume clamping to 0.0-1.0 range
- Exception handling with debug logging

---

## Implementation Details

### 1. Initialization

**Setup Checklist**:
- [ ] Create AudioService class
- [ ] Accept SettingsService in constructor
- [ ] Preload all audio files in `initialize()`
- [ ] Configure audio file paths
- [ ] Set up volume defaults

**Pseudocode**:
```dart
class AudioService {
  Future<void> initialize() async {
    try {
      // Preload background music
      await FlameAudio.audioCache.load('background_music.mp3');

      // Preload sound effects
      await FlameAudio.audioCache.loadAll([
        'button.mp3',
        'crystal.mp3',
        'game_over.mp3',
        'explosion.mp3',
        // ... more SFX
      ]);

      debugPrint('Audio initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }
}
```

**Asset Organization**:
```
assets/
├── audio/
│   ├── music/
│   │   └── background_music.mp3
│   └── sfx/
│       ├── button.mp3
│       ├── crystal.mp3
│       ├── game_over.mp3
│       ├── explosion.mp3
│       └── ...
```

**pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/audio/music/
    - assets/audio/sfx/
```

---

### 2. Background Music Management

**Architecture**:
```dart
Future<void> playBackgroundMusic() async {
  if (!_settingsService.isMusicEnabled || _appPaused) return;

  try {
    await FlameAudio.bgm.play(
      'background_music.mp3',
      volume: 0.7, // 70% volume for background music
    );
    _isMusicPlaying = true;
  } catch (e) {
    debugPrint('Failed to play music: $e');
  }
}

Future<void> pauseBackgroundMusic() async {
  if (_isMusicPlaying) {
    await FlameAudio.bgm.pause();
    _isMusicPlaying = false;
  }
}

Future<void> resumeBackgroundMusic() async {
  if (!_settingsService.isMusicEnabled || _appPaused) return;

  try {
    await FlameAudio.bgm.resume();
    _isMusicPlaying = true;
  } catch (e) {
    debugPrint('Failed to resume music: $e');
  }
}

Future<void> stopBackgroundMusic() async {
  await FlameAudio.bgm.stop();
  _isMusicPlaying = false;
}
```

**Setup Checklist**:
- [ ] Implement playBackgroundMusic with volume setting
- [ ] Add pause/resume methods
- [ ] Add stop method for cleanup
- [ ] Check settings before playing
- [ ] Check _appPaused flag
- [ ] Track _isMusicPlaying state

**Key Points**:
- **Looping**: `FlameAudio.bgm.play()` automatically loops
- **Volume**: Typically 0.5-0.8 for background music (not overpowering)
- **State tracking**: `_isMusicPlaying` prevents redundant operations
- **Settings respect**: Always check `isMusicEnabled` before playing

---

### 3. Sound Effects (Multichannel)

**Architecture**:
```dart
Future<void> playSound(String filename, {double volume = 1.0}) async {
  if (!_settingsService.isSoundEnabled || _appPaused) return;

  try {
    // Clamp volume to valid range
    final clampedVolume = volume.clamp(0.0, 1.0);

    // AudioPool allows simultaneous plays of same sound
    await FlameAudio.play(filename, volume: clampedVolume);
  } catch (e) {
    debugPrint('Failed to play sound $filename: $e');
  }
}

// Convenience methods for specific sounds
Future<void> playButtonSound() => playSound('button.mp3', volume: 0.5);
Future<void> playCrystalSound() => playSound('crystal.mp3', volume: 0.5);
Future<void> playGameOverSound() => playSound('game_over.mp3', volume: 0.5);
```

**Setup Checklist**:
- [ ] Implement generic `playSound` method
- [ ] Add volume clamping (0.0-1.0)
- [ ] Check settings before playing
- [ ] Check _appPaused flag
- [ ] Create convenience methods for common sounds
- [ ] Handle exceptions gracefully

**Multichannel Support**:
`FlameAudio.play()` uses `AudioPool` internally, allowing:
- Multiple instances of the same sound simultaneously
- No interruption if sound is already playing
- Automatic cleanup of finished sounds

**Volume Guidelines**:
- UI sounds (buttons): 0.3-0.5
- Collectibles: 0.5-0.7
- Important events (game over): 0.6-0.8
- Explosions/impacts: 0.7-0.9

---

### 4. App Lifecycle Integration

**Critical Feature**: Prevent audio in background

**Architecture**:
```dart
class AudioService {
  bool _appPaused = false; // Global pause flag

  void onAppPaused() {
    _appPaused = true;
    if (_isMusicPlaying) {
      pauseBackgroundMusic();
    }
    // SFX automatically prevented by _appPaused check
  }

  void onAppResumed() {
    _appPaused = false;
    if (_settingsService.isMusicEnabled && !_isMusicPlaying) {
      resumeBackgroundMusic();
    }
  }
}
```

**Integration in main.dart**:
```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        widget.audioService.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        widget.audioService.onAppResumed();
        break;
      default:
        break;
    }
  }
}
```

**Setup Checklist**:
- [ ] Add _appPaused boolean field
- [ ] Implement onAppPaused method
- [ ] Implement onAppResumed method
- [ ] Add WidgetsBindingObserver to MyApp state
- [ ] Override didChangeAppLifecycleState
- [ ] Handle paused, inactive, resumed states
- [ ] Remove observer in dispose

**Why This Matters**:
- **Platform compliance**: iOS/Android penalize apps playing audio in background
- **User experience**: Prevents unexpected audio when switching apps
- **Battery life**: Reduces resource usage when app is backgrounded

---

## Settings Integration

### SettingsService Properties

```dart
class SettingsService {
  bool get isMusicEnabled => _prefs.getBool('music_enabled') ?? true;
  bool get isSoundEnabled => _prefs.getBool('sound_enabled') ?? true;

  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool('music_enabled', enabled);
    notifyListeners(); // If using ChangeNotifier
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }
}
```

### Audio Settings UI

**In SettingsScreen**:
```dart
// Music toggle
SwitchListTile(
  title: Text('Background Music'),
  value: settingsService.isMusicEnabled,
  onChanged: (value) async {
    await settingsService.setMusicEnabled(value);
    if (value) {
      audioService.playBackgroundMusic();
    } else {
      audioService.pauseBackgroundMusic();
    }
  },
)

// Sound effects toggle
SwitchListTile(
  title: Text('Sound Effects'),
  value: settingsService.isSoundEnabled,
  onChanged: (value) async {
    await settingsService.setSoundEnabled(value);
    if (value) {
      audioService.playButtonSound(); // Immediate feedback
    }
  },
)
```

**Setup Checklist**:
- [ ] Add music/sound boolean properties to SettingsService
- [ ] Persist to SharedPreferences
- [ ] Create settings UI with switches
- [ ] Connect switches to AudioService
- [ ] Provide immediate audio feedback on toggle

---

## Service Locator Integration

**Registration**:
```dart
ServiceLocator.initialize(
  audioService: audioService,
  settingsService: settingsService,
  // ... other services
);
```

**Usage Anywhere**:
```dart
// In GameButton
ServiceLocator.audioService.playButtonSound();

// In game component
ServiceLocator.audioService.playCrystalSound();
```

This allows any widget or game component to play sounds without dependency injection.

---

## Common Use Cases

### 1. Menu Music Loop
```dart
// In MenuScreen.initState():
widget.audioService.playBackgroundMusic();
```

### 2. Game Start Transition
```dart
// Stop menu music, start game music (if different)
audioService.stopBackgroundMusic();
audioService.playBackgroundMusic(); // Could load different track
```

### 3. Button Press Feedback
```dart
GameButton(
  onPressed: () {
    ServiceLocator.audioService.playButtonSound();
    // ... action
  },
)
```

### 4. In-Game Events
```dart
// In Flame component collision:
void onCollisionWith(Component other) {
  if (other is CrystalComponent) {
    ServiceLocator.audioService.playCrystalSound();
  }
}
```

### 5. Game Over
```dart
void _showGameOver() {
  audioService.playGameOverSound();
  audioService.pauseBackgroundMusic();
  // Show game over dialog
}
```

---

## Video Content and Audio Coordination

### Overview

When displaying video content with audio tracks (intros, cutscenes, tutorials), proper coordination with the background music system is essential to prevent audio conflicts and ensure a smooth user experience.

### Dependencies

```yaml
dependencies:
  video_player: ^2.9.2
```

The `video_player` package provides:
- Asset and network video playback
- Audio/video synchronization
- Platform-specific optimizations (iOS, Android, Web)
- Audio session management

---

### Video Player Configuration

**Initialization Pattern**:
```dart
_videoController = VideoPlayerController.asset(
  'assets/videos/puzzle_intro.mp4',
  videoPlayerOptions: VideoPlayerOptions(
    mixWithOthers: true,  // Critical: Allows proper audio session mixing
  ),
);
await _videoController.initialize();
await _videoController.setVolume(1.0);  // Full volume (background music is paused)
await _videoController.setLooping(true);
await _videoController.play();
```

**Why `mixWithOthers: true` is Critical**:
- Required for proper audio session management on iOS and Android
- Without it, the video player forcefully takes over the audio session
- Causes conflicts when trying to resume background music
- Prevents audio interruptions from other apps

---

### Audio Lifecycle Pattern

**Principle**: The screen displaying video is responsible for managing the complete audio lifecycle.

**Full Implementation Example**:
```dart
class VideoIntroScreen extends StatefulWidget {
  final AudioService audioService;
  final Puzzle puzzle;

  const VideoIntroScreen({
    required this.audioService,
    required this.puzzle,
  });

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // STEP 1: Pause background music immediately
    widget.audioService.pauseBackgroundMusic();
    _initializeVideo();
  }

  @override
  void dispose() {
    // STEP 2: Resume music when navigating back (pop)
    widget.audioService.resumeBackgroundMusic();
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      widget.puzzle.videoPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    await _videoController.initialize();
    await _videoController.setVolume(1.0);
    await _videoController.setLooping(true);
    await _videoController.play();

    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Pause video when user navigates back via system gesture
        if (didPop && _isVideoInitialized) {
          _videoController.pause();
        }
        // Music resumption is handled in dispose()
      },
      child: Scaffold(
        body: Column(
          children: [
            // Video display
            _isVideoInitialized
                ? VideoPlayer(_videoController)
                : CircularProgressIndicator(),

            // Continue button
            GameButton(
              label: 'Start Game',
              onPressed: _onContinuePressed,
            ),
          ],
        ),
      ),
    );
  }

  void _onContinuePressed() {
    widget.audioService.playButtonSound();

    // Pause video before navigating
    if (_isVideoInitialized) {
      _videoController.pause();
    }

    // STEP 3: Resume music BEFORE pushing next screen
    // Critical: dispose() is NOT called on push, only on pop
    widget.audioService.resumeBackgroundMusic();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextScreen()),
    );
  }
}
```

**Setup Checklist**:
- [ ] Pause background music in `initState()`
- [ ] Resume music in `dispose()` (for back navigation)
- [ ] Resume music before forward navigation (push)
- [ ] Use `VideoPlayerOptions(mixWithOthers: true)`
- [ ] Implement `PopScope` for system back gestures
- [ ] Pause video before all navigation
- [ ] Dispose video controller properly

---

### Critical Pattern: Forward Navigation

**The Problem**:
Flutter's navigation stack keeps pushed screens alive. When you navigate forward using `Navigator.push()`, the current screen's `dispose()` method is **NOT called** until you eventually pop back to it. This means:
- Video keeps running in background
- Background music stays paused
- Memory is not freed

**Wrong Approach ❌**:
```dart
void _goToGameScreen() {
  // Relies on dispose() being called - but it won't be!
  Navigator.push(context, GameScreen());
}

// dispose() is NOT called yet, music stays paused!
@override
void dispose() {
  widget.audioService.resumeBackgroundMusic();
  super.dispose();
}
```

**Correct Approach ✅**:
```dart
void _goToGameScreen() {
  // Pause video
  if (_isVideoInitialized) {
    _videoController.pause();
  }

  // Explicitly resume music before push
  widget.audioService.resumeBackgroundMusic();

  // Now navigate
  Navigator.push(context, GameScreen());
}

// dispose() still resumes music as safety net for back navigation
@override
void dispose() {
  widget.audioService.resumeBackgroundMusic();
  _videoController.dispose();
  super.dispose();
}
```

**Key Insight**: You need music resumption in **two places**:
1. In `dispose()` for back navigation (pop)
2. Before `Navigator.push()` for forward navigation

---

### Back Navigation Handling

Handle system back button and gestures using `PopScope`:

```dart
@override
Widget build(BuildContext context) {
  return PopScope(
    onPopInvokedWithResult: (didPop, result) {
      // Clean up video when back navigation occurs
      if (didPop && _isVideoInitialized) {
        _videoController.pause();
      }
      // Music resumption happens in dispose()
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.audioService.playButtonSound();

            // Pause video
            if (_isVideoInitialized) {
              _videoController.pause();
            }

            // Pop (dispose() will resume music)
            Navigator.pop(context);
          },
        ),
      ),
      body: /* ... */,
    ),
  );
}
```

---

### Video Volume Guidelines

**Scenario 1: Video with Important Audio** (narration, dialogue, story)
```dart
// In initState():
widget.audioService.pauseBackgroundMusic();

// In video initialization:
await _videoController.setVolume(1.0);  // Full volume
```

**Scenario 2: Decorative Video Only** (no important audio)
```dart
// Keep background music playing:
// DON'T pause in initState()

// Mute video:
await _videoController.setVolume(0.0);  // Silent
```

**Guidelines**:
- **1.0**: Video audio is primary (music paused)
- **0.5-0.7**: Video audio mixed with quiet music (advanced)
- **0.0**: Video is decorative, music is primary

---

### Asset Organization

```
assets/
├── audio/
│   ├── music/
│   │   └── background_music.mp3
│   └── sfx/
│       └── button.mp3
└── videos/
    ├── intro.mp4
    ├── tutorial.mp4
    └── puzzle_intros/
        ├── puzzle_1_intro.mp4
        ├── puzzle_2_intro.mp4
        └── puzzle_3_intro.mp4
```

**pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/audio/music/
    - assets/audio/sfx/
    - assets/videos/
    - assets/videos/puzzle_intros/
```

**Video Format Recommendations**:
- **Codec**: H.264 (best compatibility)
- **Resolution**: 1920x1080 or lower
- **Bitrate**: 2-5 Mbps for HD quality
- **Audio**: AAC codec, 128 kbps
- **Container**: MP4

---

### Common Pitfalls

1. **Music Continues During Video**
   - **Problem**: Audio overlap, muddy sound
   - **Cause**: Forgot to pause background music
   - **Solution**: Always call `pauseBackgroundMusic()` in `initState()`

2. **Music Doesn't Resume on Forward Navigation**
   - **Problem**: Music stays paused after leaving video screen
   - **Cause**: `dispose()` not called on `Navigator.push()`
   - **Solution**: Explicitly resume music before `Navigator.push()`

3. **Audio Session Conflicts**
   - **Problem**: Audio crackles, interruptions, conflicts
   - **Cause**: Missing `VideoPlayerOptions(mixWithOthers: true)`
   - **Solution**: Always use `mixWithOthers: true` in initialization

4. **Video Continues Playing After Navigation**
   - **Problem**: Video plays in background, wastes resources
   - **Cause**: Forgot to pause video before navigation
   - **Solution**: Pause in `PopScope` callback and before all navigation

5. **Memory Leaks from Undisposed Controllers**
   - **Problem**: Video resources not released, memory grows
   - **Cause**: Missing `_videoController.dispose()` in `dispose()`
   - **Solution**: Always dispose controller in `dispose()` method

6. **Music Doesn't Respect Settings**
   - **Problem**: Music plays even when user disabled it
   - **Cause**: Not checking settings before resuming
   - **Solution**: `resumeBackgroundMusic()` already checks settings internally

---

### Settings Integration

The AudioService already respects user settings:

```dart
Future<void> resumeBackgroundMusic() async {
  // Automatically checks settings
  if (!_settingsService.isMusicEnabled || _appPaused) return;

  await FlameAudio.bgm.resume();
  _isMusicPlaying = true;
}
```

**Key Point**: You don't need to manually check settings when calling `resumeBackgroundMusic()` - it's handled automatically. This keeps video screens simple and decoupled from settings logic.

---

### Testing Checklist

Video/Music Coordination:
- [ ] Background music pauses when video screen loads
- [ ] Video audio plays clearly at appropriate volume
- [ ] Music resumes when navigating back (pop)
- [ ] Music resumes when navigating forward (push)
- [ ] Video pauses when screen is exited (both directions)
- [ ] No audio conflicts or crackling sounds

System Integration:
- [ ] System back button works correctly
- [ ] System back gesture works correctly (iOS/Android)
- [ ] App lifecycle events handled (background/foreground)
- [ ] Settings toggle respected (music enabled/disabled)

Resource Management:
- [ ] No memory leaks from video controllers
- [ ] Video stops playing after navigation
- [ ] No crashes from disposed controllers

Multi-Platform:
- [ ] Tested on iOS device
- [ ] Tested on Android device
- [ ] Tested on different screen sizes

---

### Performance Considerations

**Video File Optimization**:
- Keep videos under 10 MB when possible
- Use appropriate resolution (don't exceed device capabilities)
- Compress with H.264 codec
- Consider streaming for longer videos (>30 seconds)

**Memory Management**:
```dart
@override
void dispose() {
  // Release video memory immediately
  _videoController.pause();
  _videoController.dispose();

  // Resume audio
  widget.audioService.resumeBackgroundMusic();

  super.dispose();
}
```

**Preloading (Optional)**:
For faster video startup, you can initialize the controller earlier:
```dart
@override
void initState() {
  super.initState();
  widget.audioService.pauseBackgroundMusic();

  // Start loading immediately
  _initializeVideo();

  // Show loading indicator until _isVideoInitialized is true
}
```

---

### Advanced: Multiple Videos

If your screen shows multiple video thumbnails (like a selection screen):

```dart
class VideoThumbnail extends StatefulWidget {
  final String videoPath;
  final bool isVisible; // Only play if visible

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.videoPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller.initialize().then((_) {
      _controller.setVolume(0.0); // Mute thumbnails
      _controller.setLooping(true);
      if (widget.isVisible) {
        _controller.play();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(VideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Pause/play based on visibility
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.play();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : Container(color: Colors.black);
  }
}
```

**Key Points for Multiple Videos**:
- Always mute thumbnail videos (`setVolume(0.0)`)
- Keep background music playing
- Pause videos that scroll out of view
- Dispose controllers when thumbnails are removed

---

## Advanced Features (Optional)

### 1. Multiple Music Tracks
```dart
Future<void> playMusic(String trackName) async {
  await stopBackgroundMusic();
  await FlameAudio.bgm.play('$trackName.mp3', volume: 0.7);
}

// Usage:
audioService.playMusic('menu_theme');
audioService.playMusic('game_theme');
audioService.playMusic('boss_theme');
```

### 2. Dynamic Volume Control
```dart
Future<void> setMusicVolume(double volume) async {
  _musicVolume = volume.clamp(0.0, 1.0);
  FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
}

Future<void> setSfxVolume(double volume) async {
  _sfxVolume = volume.clamp(0.0, 1.0);
  // Store for use in playSound calls
}
```

### 3. Fade In/Out
```dart
Future<void> fadeMusicOut({Duration duration = const Duration(seconds: 2)}) async {
  const steps = 20;
  final stepDuration = duration.milliseconds ~/ steps;

  for (int i = steps; i >= 0; i--) {
    await FlameAudio.bgm.audioPlayer.setVolume(i / steps * 0.7);
    await Future.delayed(Duration(milliseconds: stepDuration));
  }

  await stopBackgroundMusic();
}
```

### 4. Sound Variations
```dart
final explosionSounds = ['explosion_1.mp3', 'explosion_2.mp3', 'explosion_3.mp3'];

Future<void> playExplosionSound() async {
  final sound = explosionSounds[Random().nextInt(explosionSounds.length)];
  await playSound(sound, volume: 0.7);
}
```

---

## Performance Optimization

### 1. Preloading
Always preload in `initialize()` to avoid runtime delays:
```dart
await FlameAudio.audioCache.loadAll([...]);
```

### 2. Audio Compression
- Use **MP3** for music (smaller file size)
- Use **MP3 or OGG** for SFX
- Avoid uncompressed WAV files
- Target bitrate: 128-192 kbps for music, 96 kbps for SFX

### 3. Short SFX
Keep sound effects under 2 seconds when possible:
- Faster loading
- Smaller memory footprint
- Better multichannel performance

### 4. Dispose Properly
Clean up in app disposal:
```dart
@override
void dispose() {
  audioService.stopBackgroundMusic();
  FlameAudio.audioCache.clearAll();
  super.dispose();
}
```

---

## Testing Recommendations

1. **Settings toggles**: Verify music/SFX can be enabled/disabled
2. **Background pause**: Test app backgrounding stops audio
3. **Foreground resume**: Test app resuming restarts audio (if enabled)
4. **Multichannel**: Play multiple SFX simultaneously
5. **Volume levels**: Ensure music doesn't overpower SFX
6. **Missing files**: Handle missing audio files gracefully
7. **Different devices**: Test on various Android/iOS devices

---

## Common Pitfalls

1. **Playing audio in background**
   - **Problem**: App plays audio when user switches away
   - **Solution**: Implement lifecycle handling with _appPaused flag

2. **No volume control**
   - **Problem**: Audio is too loud or too quiet
   - **Solution**: Set appropriate volumes for music (0.5-0.7) and SFX (0.3-0.8)

3. **SFX interrupting each other**
   - **Problem**: Only one instance of sound plays at a time
   - **Solution**: Use FlameAudio.play() which uses AudioPool

4. **Not respecting user settings**
   - **Problem**: Audio plays even when user disabled it
   - **Solution**: Always check SettingsService before playing

5. **Memory leaks**
   - **Problem**: Audio files not released
   - **Solution**: Call clearAll() on app disposal

6. **Laggy audio**
   - **Problem**: Delay when playing sounds
   - **Solution**: Preload all audio in initialize()

---

## Audio Asset Checklist

- [ ] Create `assets/audio/music/` directory
- [ ] Create `assets/audio/sfx/` directory
- [ ] Add background music track(s) (MP3, 128-192 kbps)
- [ ] Add button sound effect
- [ ] Add collectible sound effects
- [ ] Add game over sound effect
- [ ] Add success/failure sound effects
- [ ] Register all audio in pubspec.yaml
- [ ] Test all audio files load correctly

---

## Next Steps

After implementing audio system:
- Integrate with **Service Architecture** (06_Service_Architecture.md)
- Connect to **Settings & Persistence** (05_Statistics_And_Persistence.md)
- Use in **Shared UI Components** (01_Shared_UI_Components.md) for button feedback
- Wire up to **Flame game components** (07_Flame_Integration.md)

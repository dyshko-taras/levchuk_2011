# Privacy Plugin

A federated Flutter plugin that handles app initialization, privacy policy management, and WebView functionality with AppsFlyer integration and immersive Android experience. The plugin uses a modular architecture with optional feature packages.

## Features

- **Complete App Initialization**: AppsFlyer integration, user ID generation, Google Ad ID retrieval with 10-second timeout
- **Privacy Policy Management**: Automatic privacy policy acceptance flow with connection retry loops
- **Push Notifications**: Firebase Cloud Messaging integration with automatic permission handling (optional module)
- **Advanced WebView**: Full-featured WebView with file uploads, popup windows, deeplinks, and pull-to-refresh
- **Display Mode Control**: Immersive and normal display modes for Android with seamless transitions
- **Orientation Management**: Automatic orientation unlocking for WebView with host app restoration
- **Back Button Handling**: Context-aware Android back button management with quit confirmation
- **Connectivity Checking**: Real internet connection verification with automatic retry dialogs
- **Multi-language Support**: Built-in localization for 11 languages with automatic device locale detection
- **Event-Driven Architecture**: Clean separation between plugin logic and host app UI
- **Modular Design**: Optional feature packages that auto-register when added to pubspec.yaml

## Architecture

The plugin follows a federated architecture with auto-registering modules:

```
packages/
├── privacy_plugin/                    # Core plugin (required)
├── privacy_plugin_platform_interface/ # Shared types and module registry
├── privacy_plugin_appsflyer/          # AppsFlyer integration (optional)
├── privacy_plugin_fcm/                # Push notifications (optional)
├── privacy_plugin_diia/               # Ukraine Diia ID support (optional)
└── privacy_plugin_cleartext/          # Cleartext HTTP support (optional)
```

**Key components:**
- **PrivacyPluginService** - Main singleton service handling initialization and state management
- **PrivacyNavigationController** - Direct navigation for WebView screens with proper display mode switching
- **LocalizationService** - Built-in multi-language support (11 languages)
- **UrlHandlerRegistry** - Generic URL handler system for optional module deep links
- **PrivacyPluginModuleRegistry** - Auto-registration system for optional modules

## Installation

### Core Plugin (Required)

Add the core plugin and platform interface to your `pubspec.yaml`:

```yaml
dependencies:
  privacy_plugin:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin
  privacy_plugin_platform_interface:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_platform_interface
```

### Optional Modules

Add only the modules you need. Modules auto-register when added - no manual setup required.

**AppsFlyer Integration:**
```yaml
  privacy_plugin_appsflyer:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_appsflyer
```

**Firebase Cloud Messaging (Push Notifications):**
```yaml
  privacy_plugin_fcm:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_fcm
```

**Diia ID Support (Ukraine):**
```yaml
  privacy_plugin_diia:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_diia
```

**Cleartext HTTP Support:**
```yaml
  privacy_plugin_cleartext:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_cleartext
```

### Local Development

For local development, add `dependency_overrides` to use path dependencies:

```yaml
dependencies:
  privacy_plugin:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin
  privacy_plugin_platform_interface:
    git:
      url: https://gitlab.com/casino-slots/webview-plugin.git
      path: packages/privacy_plugin_platform_interface

dependency_overrides:
  privacy_plugin:
    path: ../path/to/webview-plugin/packages/privacy_plugin
  privacy_plugin_platform_interface:
    path: ../path/to/webview-plugin/packages/privacy_plugin_platform_interface
  # Add overrides for any optional modules you're developing
  privacy_plugin_appsflyer:
    path: ../path/to/webview-plugin/packages/privacy_plugin_appsflyer
```

## Module Auto-Registration

Modules automatically register when added to pubspec.yaml using Flutter's `dartPluginClass` mechanism. No manual registration calls are needed in your code.

**How it works:**
1. Add module to `pubspec.yaml`
2. Run `flutter pub get`
3. Module's `registerWith()` method is called automatically during app startup
4. Module functionality becomes available immediately

**Verify module registration:**
```dart
// Check if a module is available
final hasAppsFlyer = PrivacyPluginModuleRegistry.instance.has<AppsFlyerModuleInterface>();
final hasFcm = PrivacyPluginModuleRegistry.instance.has<FcmModuleInterface>();
```

## Setup

### 1. Android Configuration

The core plugin automatically includes essential permissions:

**Permissions (automatically included):**
- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`
- `com.google.android.gms.permission.AD_ID`
- `android.permission.ACCESS_WIFI_STATE`

**Optional module permissions are added automatically when modules are included.**

**Optional:** Configure your styles in `android/app/src/main/res/values/styles.xml` for optimal immersive mode support:

```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
</style>

<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">?android:colorBackground</item>
    <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
</style>
```

**Your MainActivity.kt becomes minimal:**
```kotlin
package com.yourapp.package

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Privacy plugin handles all native functionality
}
```

### 2. FCM Module Setup (if using push notifications)

1. **Add google-services.json** to your app:
   ```
   android/app/google-services.json
   ```

2. **Apply Google Services plugin** in your app's `build.gradle` files:

   In `android/build.gradle.kts`:
   ```kotlin
   buildscript {
       dependencies {
           classpath("com.google.gms:google-services:4.4.2")
       }
   }
   ```

   In `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

### 3. Flutter Integration

#### ⚠️ CRITICAL: Initialization Sequence

**Race Condition Warning:** The plugin's `init()` method MUST complete before registering the Navigator and calling `startInitialization()`. Failure to follow this sequence will result in "Plugin not initialized" errors.

**Required Sequence:**
1. Call `PrivacyPluginService.instance.init(config, autoStart: false)`
2. Wait for `init()` to complete (await the Future)
3. Register Navigator via `registerNavigator(Navigator.of(context))`
4. Call `startInitialization()`

**Why This Matters:**
- `init()` configures the plugin asynchronously (fetches build config, sets up AppsFlyer)
- If Navigator registers before `init()` completes, `startInitialization()` will fail
- Using `autoStart: false` gives you control over the exact timing

**Incorrect (causes race condition):**
```dart
// BAD: Both run in parallel
_initializePlugin();  // Calls init() async
_registerNavigator(); // Might happen before init() completes
```

**Correct (sequential):**
```dart
// GOOD: Sequential execution
await PrivacyPluginService.instance.init(config, autoStart: false);
// Now Navigator can be registered safely
PrivacyPluginService.instance.registerNavigator(Navigator.of(context));
await PrivacyPluginService.instance.startInitialization();
```

#### Main App Setup (Complete Implementation)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:privacy_plugin/privacy_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrivacyPluginInitState _currentState = PrivacyPluginInitState.idle;
  bool _pluginConfigured = false;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
    _initializePlugin();
  }

  void _listenToEvents() {
    PrivacyPluginService.instance.events.listen((event) {
      if (!mounted) return;

      switch (event.type) {
        case PrivacyPluginEventType.initializationStarted:
          setState(() => _currentState = PrivacyPluginInitState.loading);
          break;
        case PrivacyPluginEventType.privacyPolicyRequired:
          setState(() => _currentState = PrivacyPluginInitState.privacyRequired);
          break;
        case PrivacyPluginEventType.initializationCompleted:
          setState(() => _currentState = PrivacyPluginInitState.ready);
          break;
        case PrivacyPluginEventType.error:
          setState(() => _currentState = PrivacyPluginInitState.error);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _initializePlugin() async {
    final config = PrivacyPluginConfig(
      installerParam: 'INSTALLER_PARAM',
      userIdParam: 'USER_ID_PARAM',
      gaidParam: 'GAID_PARAM',
      appsflyerIdParam: 'APPSFLYER_ID_PARAM',
      appsflyerSourceParam: 'APPSFLYER_SOURCE_PARAM',
      appsflyerCampaignParam: 'APPSFLYER_CAMPAIGN_PARAM',
      appsflyerDevKey: 'APPSFLYER_DEV_KEY',
      supportLink: 'SUPPORT_LINK',
      privacyLink: 'PRIVACY_LINK',
      privacyCallback: 'PRIVACY_CALLBACK',
      privacyAcceptedParam: 'PRIVACY_ACCEPTED_PARAM',
      notificationsSkipParam: 'NOTIFICATION_SKIP_PARAM',
      notificationsTokenParam: 'NOTIFICATIONS_TOKEN_PARAM',
      verboseWebViewLogging: kDebugMode,
    );

    // CRITICAL: Use autoStart: false to control timing
    await PrivacyPluginService.instance.init(
      config,
      hostAppOrientations: [DeviceOrientation.portraitUp],
      autoStart: false,
    );

    setState(() => _pluginConfigured = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_currentState == PrivacyPluginInitState.ready) {
      return const YourMainScreen();
    } else if (_pluginConfigured) {
      return LoadingScreen(
        onNavigatorRegistered: _startInitialization,
      );
    } else {
      return const SimpleLoadingScreen();
    }
  }

  Future<void> _startInitialization() async {
    await PrivacyPluginService.instance.startInitialization();
  }
}

// Simple loading screen WITHOUT Navigator (shown during init())
class SimpleLoadingScreen extends StatelessWidget {
  const SimpleLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

#### Critical: Navigator Registration

**REQUIRED for WebView navigation to work:**

The LoadingScreen must:
1. Register Navigator in postFrameCallback
2. Call the initialization callback AFTER Navigator is registered
3. Never call startInitialization() before Navigator registration completes

```dart
class LoadingScreen extends StatefulWidget {
  final VoidCallback onNavigatorRegistered;

  const LoadingScreen({
    required this.onNavigatorRegistered,
    super.key,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _setupEventListening();

    // CRITICAL: Register Navigator, THEN trigger initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Step 1: Register Navigator
        PrivacyPluginService.instance.registerNavigator(Navigator.of(context));

        // Step 2: ONLY NOW call initialization callback
        widget.onNavigatorRegistered();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to register Navigator: $e');
        }
      }
    });
  }

  void _setupEventListening() {
    PrivacyPluginService.instance.events.listen((event) {
      if (!mounted) return;

      switch (event.type) {
        case PrivacyPluginEventType.initializationStarted:
          setState(() => _loadingText = 'Initializing...');
          break;
        case PrivacyPluginEventType.appsflyerInitialized:
          setState(() => _loadingText = 'Setting up analytics...');
          break;
        case PrivacyPluginEventType.privacyPolicyRequired:
          setState(() => _loadingText = 'Loading privacy policy...');
          break;
        case PrivacyPluginEventType.connectionRequired:
          setState(() => _loadingText = 'Checking connection...');
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(_loadingText),
          ],
        ),
      ),
    );
  }
}
```

## Usage

### Basic Operations

```dart
// Access plugin data
final userId = PrivacyPluginService.instance.userId;
final appsflyerId = PrivacyPluginService.instance.appsflyerId;
final googleAdId = PrivacyPluginService.instance.googleAdId;
final analyticsParams = PrivacyPluginService.instance.analyticsParams;
final privacyAccepted = PrivacyPluginService.instance.privacyAccepted;

// Direct navigation actions (requires navigator registration)
await PrivacyPluginService.instance.openWebView('https://example.com');
await PrivacyPluginService.instance.openPrivacyPolicy();
await PrivacyPluginService.instance.openCustomerSupport();

// Utility functions
final hasConnection = await PrivacyPluginService.instance.hasConnection();
await PrivacyPluginService.instance.moveToBackground();

// Handle back button
await PrivacyPluginService.instance.handleBackButtonPress();

// Show built-in dialogs
await PrivacyPluginService.instance.showQuitConfirmationDialog();
```

### Privacy Policy Integration

Your privacy policy webpage should include this JavaScript code:

```javascript
// When user accepts privacy policy
if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
  window.flutter_inappwebview.callHandler('[PRIVACY_CALLBACK]');
}
```

## Advanced Usage

### Orientation Management

The plugin automatically manages device orientation for optimal WebView experience:

- **WebView screens**: Unlocks all orientations (portrait/landscape) for better user experience
- **Host app restoration**: Restores original orientation restrictions when WebView closes
- **Backward compatible**: Optional parameter maintains existing functionality

```dart
// Option 1: No orientation restrictions (default behavior)
await PrivacyPluginService.instance.init(config);

// Option 2: Specify host app orientation restrictions to restore after WebView
await PrivacyPluginService.instance.init(
  config,
  hostAppOrientations: [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ], // WebView allows all orientations, restores these when closed
);

// Option 3: Portrait-only host app
await PrivacyPluginService.instance.init(
  config,
  hostAppOrientations: [DeviceOrientation.portraitUp],
);
```

**Behavior:**
- When WebView opens → All orientations unlocked automatically
- When WebView closes → Host app orientations restored (if specified)
- No host orientations specified → No restoration (Flutter default behavior)

### Manual Initialization Control

By default, calling `init()` automatically starts the initialization process. For advanced use cases where you need to control the exact timing of initialization (e.g., waiting for user permissions), you can disable auto-start:

```dart
// Configure plugin without starting initialization
await PrivacyPluginService.instance.init(config, autoStart: false);

// Later, when you're ready to start initialization
await PrivacyPluginService.instance.startInitialization();
```

### Built-in WebView Features

The plugin includes a complete WebView implementation with:

- **Automatic URL parameter injection**: All analytics parameters are automatically added to WebView URLs
- **File upload support**: Gallery, documents, multiple selection
- **Popup window handling**: OAuth, Google Pay, payment gateways with dynamic titles
- **Deeplink support**: All custom URL schemes automatically handled via url_launcher
- **Pull-to-refresh**: Native gesture implementation
- **Display mode management**: Automatic switching between immersive and normal modes
- **Orientation management**: Automatic unlocking for WebView, restoration for host app
- **Back button handling**: Context-aware navigation with WebView history support
- **Connection checking**: Automatic retry dialogs for network issues
- **Multi-language dialogs**: Built-in localized "App Not Installed" dialogs

### Custom WebView Usage

If you need to create custom WebView screens, use the plugin's helper methods:

```dart
// Build URL with analytics parameters
final finalUrl = PrivacyPluginService.instance.buildWebViewUrl('https://example.com');

// Get proper headers (User-Agent, Accept-Language)
final headers = PrivacyPluginService.instance.getWebViewHeaders();

// Use in your custom WebView
InAppWebView(
  initialUrlRequest: URLRequest(
    url: WebUri(finalUrl),
    headers: headers,
  ),
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    supportMultipleWindows: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowFileAccess: true,
    useShouldOverrideUrlLoading: true,
    transparentBackground: true,
    useHybridComposition: false,
  ),
)
```

## Configuration

### Required Parameters

```dart
PrivacyPluginConfig(
  appsflyerDevKey: 'APPSFLYER_DEV_KEY',        // AppsFlyer dev key
  supportLink: 'SUPPORT_LINK',                  // Support page URL
  privacyLink: 'PRIVACY_LINK',                  // Privacy policy URL
  privacyCallback: 'PRIVACY_CALLBACK',          // JS callback name
  privacyAcceptedParam: 'PRIVACY_ACCEPTED_PARAM', // URL parameter name
  notificationsSkipParam: 'NOTIFICATION_SKIP_PARAM',
  notificationsTokenParam: 'NOTIFICATIONS_TOKEN_PARAM',
)
```

### URL Parameters (automatically injected)

```dart
PrivacyPluginConfig(
  installerParam: 'INSTALLER_PARAM',
  userIdParam: 'USER_ID_PARAM',
  gaidParam: 'GAID_PARAM',
  appsflyerIdParam: 'APPSFLYER_ID_PARAM',
  appsflyerSourceParam: 'APPSFLYER_SOURCE_PARAM',
  appsflyerCampaignParam: 'APPSFLYER_CAMPAIGN_PARAM',
  notificationsTokenParam: 'NOTIFICATIONS_TOKEN_PARAM',
)
```

## URL Handler System

The plugin uses a generic URL handler registry that allows optional modules to register their own URL handlers. This enables deep link handling without the core plugin knowing about specific modules.

**How it works:**
1. Module registers URL handler in its `registerWith()` method
2. When WebView encounters a URL, it checks registered handlers
3. First matching handler processes the URL
4. If no handler matches, default behavior (launchUrl) is used

**Example: Custom URL handler from module**
```dart
// In your module's registerWith():
UrlHandlerRegistry.instance.register(
  UrlHandlerEntry(
    moduleId: 'my_module',
    priority: 10,
    canHandle: (url) => url.startsWith('myscheme://'),
    handle: (url) async {
      // Handle the URL
      return UrlHandlerResult.handled;
    },
  ),
);
```

## Push Notifications (FCM Module)

When `privacy_plugin_fcm` is installed, the plugin provides automatic Firebase Cloud Messaging support.

### How It Works

- **Automatic Permission Request**: When any WebView opens, the plugin automatically requests notification permission (Android 13+)
- **Automatic Topic Subscription**: After permission is granted, subscribes to FCM topic using full device locale in BCP 47 format (e.g., "en-US", "ru-BY", "sk-SK")
- **FCM Token Injection**: FCM token is automatically injected into WebView URLs using the configured parameter name
- **Conditional Skip**: If the WebView URL contains the `notificationsSkipParam` (e.g., `?skipNotificationConsent=true`), permission request is skipped
- **Persistent Subscriptions**: Topic subscriptions persist on Firebase servers and don't need to be refreshed on each app launch
- **Built-in FCM Service**: The plugin includes a complete FCM service that receives and displays notifications
- **Notification Display**: Notifications are automatically shown with title, body, and click handling

### URL Parameter Behavior

```dart
// Will request notification permission
await PrivacyPluginService.instance.openWebView('https://example.com');

// Will skip notification permission request
await PrivacyPluginService.instance.openWebView('https://example.com?skipNotificationConsent=true');
await PrivacyPluginService.instance.openWebView('https://example.com?skipNotificationConsent=false'); // Also skips
```

**Note**: The parameter just needs to be present in the URL - its value doesn't matter.

### Manual Permission Check

```dart
import 'package:privacy_plugin_platform_interface/privacy_plugin_platform_interface.dart';

// Check if FCM module is available
final hasFcm = PrivacyPluginModuleRegistry.instance.has<FcmModuleInterface>();

if (hasFcm) {
  final fcmModule = PrivacyPluginModuleRegistry.instance.get<FcmModuleInterface>()!;

  // Check if permission is granted
  final hasPermission = await fcmModule.checkPermission();

  // Request permission
  final granted = await fcmModule.requestPermission();

  // Subscribe to topic
  await fcmModule.subscribeToTopic('premium_users');
}
```

### Topic Management

The plugin automatically subscribes to a locale-based topic after permission is granted, using the full device locale:

```dart
// Automatic subscription (called internally by plugin)
await fcmModule.subscribeToLocaleTopic();
// Device locale en-US → subscribes to "en-US" topic
// Device locale ru-BY → subscribes to "ru-BY" topic
// Device locale sk-SK → subscribes to "sk-SK" topic

// Subscribe to custom topic
await fcmModule.subscribeToTopic('premium_users');

// Unsubscribe from topic
await fcmModule.unsubscribeFromTopic('premium_users');
```

**Topic Subscription Behavior:**
- Plugin automatically subscribes to topic matching the full device locale in BCP 47 format
- Examples: "en-US" (US English), "ru-BY" (Belarusian Russian), "sk-SK" (Slovak)
- Uses `Locale.toLanguageTag()` for precise locale identification
- No filtering or fallback logic - subscribes directly to exact device locale
- Subscriptions persist indefinitely and don't need to be refreshed on each app launch
- Send targeted notifications to specific locale groups (e.g., "en-US" for US English users)

### Sending Notifications

To send notifications to locale-based topics, use Firebase Cloud Messaging API:

```bash
# Send to US English speakers
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/en-US",
    "notification": {
      "title": "Hello",
      "body": "This is a test notification for US English users"
    }
  }'

# Send to Slovak users
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/sk-SK",
    "notification": {
      "title": "Ahoj",
      "body": "Toto je testovacia notifikácia pre slovenských používateľov"
    }
  }'
```

### FCM Token

The plugin automatically handles FCM token generation, refresh, and injection into WebView URLs. The token is added to all WebView URLs using the parameter name configured in `notificationsTokenParam`. This allows your web backend to:
- Receive the FCM token via URL parameter
- Send targeted notifications to specific users
- Track notification delivery and engagement

## Plugin Events

The plugin emits the following events:

- `initializationStarted` - Plugin started initialization process
- `privacyPolicyRequired` - Privacy policy needs to be accepted (automatically opens WebView)
- `privacyPolicyAccepted` - Privacy policy was accepted by user
- `initializationCompleted` - Initialization finished successfully, app is ready
- `backButtonPressed` - Android back button was pressed
- `connectionRequired` - Network connection is required (fallback event if no navigator)
- `appsflyerInitialized` - AppsFlyer SDK initialization completed
- `appsflyerConversionDataReceived` - AppsFlyer conversion data received (or timeout)
- `webViewClosed` - WebView screen was closed
- `error` - An error occurred during initialization

### Event Data Structure

```dart
class PrivacyPluginEvent {
  final PrivacyPluginEventType type;
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime timestamp;
}
```

## Available Data

Access plugin state through `PrivacyPluginService.instance`:

- `userId` - Generated UUID for the user (persisted in SharedPreferences)
- `installerPackage` - App installer package name (or "debug" in debug mode)
- `googleAdId` - Google Advertising ID
- `appsflyerId` - AppsFlyer unique ID
- `appsflyerSource` - AppsFlyer attribution source (media_source or "organic")
- `privacyAccepted` - Privacy policy acceptance status
- `analyticsParams` - Map of all analytics parameters
- `config` - Current plugin configuration
- `state` - Current initialization state (idle, loading, privacyRequired, ready, error)
- `userAgent` - Dynamic user agent string based on device info (auto-generated using device_info_plus)

## Supported Languages

The plugin includes built-in localization for the following languages:

- **English** (en) - Default fallback
- **German** (de) - Deutsch
- **Spanish** (es) - Español
- **French** (fr) - Français
- **Italian** (it) - Italiano
- **Polish** (pl) - Polski
- **Portuguese** (pt) - Português
- **Russian** (ru) - Русский
- **Slovak** (sk) - Slovenčina
- **Turkish** (tr) - Türkçe
- **Ukrainian** (uk) - Українська

The plugin automatically detects the device locale and uses the appropriate language for dialogs and messages.

## Key Features

### AppsFlyer Integration (optional module)
- **SDK Version**: 6.17.0
- **Initialization**: Automatic with debug logging support
- **Attribution tracking**: 10-second timeout for conversion data
- **Customer user ID**: Automatically set with generated UUID

### Display Mode Management
- **Immersive mode**: Complete fullscreen for non-WebView screens
- **Normal mode**: Standard system bars for WebView screens
- **Automatic switching**: Seamless transitions between modes
- **Android 15 compatible**: Proper edge-to-edge support

### Orientation Management
- **WebView orientation unlock**: All orientations enabled for optimal user experience
- **Host app restoration**: Original orientation restrictions restored after WebView closes
- **Configuration options**: Optional `hostAppOrientations` parameter in `init()` method
- **Backward compatible**: Existing apps continue working without changes

### WebView Features
- **flutter_inappwebview**: Version 6.1.5
- **Dynamic user agent**: Automatically generated based on device info
- **File uploads**: Full support for gallery and document selection
- **Popup windows**: OAuth, payments, with dynamic titles
- **Deeplinks**: Universal custom URL scheme handling
- **Pull-to-refresh**: Native gesture support
- **Error handling**: Silent recovery, no user-facing errors

## Common Pitfalls

### 1. Race Condition: Navigator Registration Before init() Completes

**Symptom:** Error "Plugin not initialized. Call init() first."

**Cause:** Calling `startInitialization()` before `init()` completes.

**Solution:** Use `autoStart: false` and control sequence manually:
```dart
// Phase 1: Configure plugin
await PrivacyPluginService.instance.init(config, autoStart: false);

// Phase 2: Register Navigator (in LoadingScreen)
PrivacyPluginService.instance.registerNavigator(Navigator.of(context));

// Phase 3: Start initialization
await PrivacyPluginService.instance.startInitialization();
```

### 2. Using Timers to "Fix" Race Conditions

**Wrong Approach:**
```dart
// BAD: Arbitrary delays don't guarantee correct order
await Future.delayed(Duration(milliseconds: 100));
```

**Correct Approach:** Use proper async/await and callbacks to ensure sequential execution.

### 3. Showing LoadingScreen Before Plugin is Configured

**Problem:** LoadingScreen registers Navigator, but plugin isn't ready yet.

**Solution:** Show a simple loading screen without Navigator until `init()` completes, then show LoadingScreen.

```dart
Widget _buildCurrentScreen() {
  if (_currentState == PrivacyPluginInitState.ready) {
    return const YourMainScreen();
  } else if (_pluginConfigured) {
    // Plugin configured, NOW show loading screen with Navigator
    return LoadingScreen(onNavigatorRegistered: _startInitialization);
  } else {
    // Plugin NOT configured yet, show simple loading WITHOUT Navigator
    return const SimpleLoadingScreen();
  }
}
```

### 4. Missing Platform Interface Package

**Symptom:** Module types not found.

**Solution:** Always include `privacy_plugin_platform_interface` in dependencies.

### 5. Module Not Auto-Registering

**Symptom:** Module functionality not available.

**Solution:**
- Ensure `flutter pub get` was run after adding module
- Check module is in dependencies (not dev_dependencies)
- Verify pubspec.yaml path is correct

## Known Issues

### 1. App Stuck on Loading Screen ✅ FIXED
- **Problem**: Privacy plugin's init() method only configures the plugin but doesn't start the actual initialization process
- **Solution**: The plugin now automatically starts initialization when `init()` is called. No additional steps required.
- **For advanced users**: Use `init(config, autoStart: false)` if you need manual control over initialization timing

## License

This plugin is proprietary software.

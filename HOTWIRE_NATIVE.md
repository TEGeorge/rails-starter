# Hotwire Native Mobile Apps Guide

This guide explains how to add native iOS and Android apps to the Rails Starter Template using Hotwire Native.

## Overview

Hotwire Native lets you build native mobile apps by wrapping your existing Rails web app in a native shell. You write your screens once in HTML/CSS and reuse them across web, iOS, and Android.

### What's Already Configured

Your Rails starter template now includes:

✅ **Hotwire Native Bridge** - JavaScript package for bridge components
✅ **Path Configuration Endpoints** - JSON endpoints for iOS and Android navigation rules
✅ **Turbo Native Detection** - Helper methods to detect mobile app requests
✅ **Authentication Support** - Cookie-based auth works automatically with mobile apps

### Technology Stack

- **iOS**: Swift 5.3+, iOS 14+, Xcode
- **Android**: Kotlin, Android SDK 28+, Android Studio
- **Backend**: Rails 8.1.1 with Turbo Rails (already installed)

---

## Rails Backend (Already Set Up)

### 1. Hotwire Native Bridge Package

Added to `config/importmap.rb`:
```ruby
pin "@hotwired/hotwire-native-bridge",
  to: "https://cdn.jsdelivr.net/npm/@hotwired/hotwire-native-bridge@1.0.0/dist/hotwire-native-bridge.umd.js"
```

### 2. Path Configuration Endpoints

**Routes** (`config/routes.rb`):
```ruby
namespace :turbo do
  namespace :ios do
    resource :path_configuration, only: [:show]
  end
  namespace :android do
    resource :path_configuration, only: [:show]
  end
end
```

**Endpoints:**
- iOS: `/turbo/ios/path_configuration.json`
- Android: `/turbo/android/path_configuration.json`

**Controllers:**
- `app/controllers/turbo/ios/path_configurations_controller.rb`
- `app/controllers/turbo/android/path_configurations_controller.rb`

These controllers return JSON configuration that controls navigation behavior in your mobile apps. You can customize presentation styles (modal, push, etc.) per URL pattern without releasing app updates.

### 3. Mobile App Detection

The `TurboNativeDetection` concern (included in `ApplicationController`) provides helper methods:

```ruby
# In any controller or view:
turbo_native_app?    # true if iOS or Android app
turbo_ios_app?       # true if iOS app
turbo_android_app?   # true if Android app
```

**Example usage in views:**
```erb
<% if turbo_native_app? %>
  <div class="mobile-native-header">Native App</div>
<% else %>
  <div class="web-header">Web Browser</div>
<% end %>
```

---

## Building the iOS App

### Prerequisites

- **macOS** with Xcode installed
- **Xcode 14+** recommended
- **CocoaPods or Swift Package Manager** (SPM recommended)

### Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose **iOS** → **App**
4. Project settings:
   - Interface: **Storyboard** (not SwiftUI - better Hotwire support)
   - Language: **Swift**
   - Minimum Deployment: **iOS 14.0**

### Step 2: Add Hotwire Native Dependency

**Using Swift Package Manager (Recommended):**

1. In Xcode: File → Add Package Dependencies
2. Enter URL: `https://github.com/hotwired/hotwire-native-ios`
3. Version: **1.2.2** or later
4. Click "Add Package"

### Step 3: Configure SceneDelegate

Replace `SceneDelegate.swift` with:

```swift
import UIKit
import HotwireNative

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let rootURL = URL(string: "https://yourapp.com")!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Configure Hotwire
        Hotwire.config.applicationUserAgent = "Turbo Native iOS"

        // Load path configuration (local fallback + remote)
        let localPathConfigURL = Bundle.main.url(
            forResource: "path-configuration",
            withExtension: "json"
        )!
        let remotePathConfigURL = rootURL.appending(
            path: "turbo/ios/path_configuration.json"
        )

        Hotwire.loadPathConfiguration(from: [
            .file(localPathConfigURL),
            .server(remotePathConfigURL)
        ])

        // Set up navigation
        let navigationController = UINavigationController()
        let session = Session(navigator: navigationController)
        session.visit(rootURL)

        // Configure window
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
```

### Step 4: Add Local Path Configuration

Create `path-configuration.json` in your Xcode project root:

```json
{
  "settings": {
  },
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "presentation": "modal"
      }
    },
    {
      "patterns": ["/signup$", "/login$"],
      "properties": {
        "presentation": "modal"
      }
    }
  ]
}
```

Add this file to your Xcode project (drag and drop, ensure "Copy items if needed" is checked).

### Step 5: Update Info.plist

Add these keys to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- For development only - remove in production -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Step 6: Test Locally

For local development, update `rootURL` to:
```swift
private let rootURL = URL(string: "http://localhost:3000")!
```

Then run your Rails server:
```bash
bin/dev
```

Build and run the iOS app in Xcode simulator.

### Estimated Time

- **Initial setup**: 4-8 hours (first time)
- **Testing**: 2-4 hours
- **App Store prep**: 4-8 hours
- **Total**: 10-20 hours

---

## Building the Android App

### Prerequisites

- **Android Studio** installed
- **Android SDK 28+** (API level 28 / Android 9.0)
- **Kotlin** (comes with Android Studio)

### Step 1: Create Android Studio Project

1. Open Android Studio
2. File → New → New Project
3. Choose **Empty Views Activity**
4. Project settings:
   - Language: **Kotlin**
   - Minimum SDK: **API 28 (Android 9.0)**
   - Build configuration: **Kotlin DSL** (build.gradle.kts)

### Step 2: Add Hotwire Native Dependencies

Edit `app/build.gradle.kts`:

```kotlin
dependencies {
    // Hotwire Native
    implementation("dev.hotwire:core:1.2.4")
    implementation("dev.hotwire:navigation-fragments:1.2.4")

    // Standard Android dependencies
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
}
```

**Or using `libs.versions.toml` (recommended):**

Create/edit `gradle/libs.versions.toml`:
```toml
[versions]
hotwire = "1.2.4"

[libraries]
hotwire-core = { module = "dev.hotwire:core", version.ref = "hotwire" }
hotwire-navigation-fragments = { module = "dev.hotwire:navigation-fragments", version.ref = "hotwire" }
```

Then in `app/build.gradle.kts`:
```kotlin
dependencies {
    implementation(libs.hotwire.core)
    implementation(libs.hotwire.navigation.fragments)
}
```

Sync Gradle after making changes.

### Step 3: Create Application Class

Create `MainApplication.kt`:

```kotlin
package com.yourapp

import android.app.Application
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.path.PathConfiguration

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                assetFilePath = "json/path-configuration.json",
                remoteFileUrl = "https://yourapp.com/turbo/android/path_configuration.json"
            )
        )

        Hotwire.config.userAgent = "Turbo Native Android"
    }
}
```

Register in `AndroidManifest.xml`:
```xml
<application
    android:name=".MainApplication"
    ...>
```

### Step 4: Create MainActivity

Replace `MainActivity.kt`:

```kotlin
package com.yourapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.navigator.NavigatorConfiguration

class MainActivity : HotwireActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun navigatorConfigurations() = listOf(
        NavigatorConfiguration(
            name = "main",
            startLocation = "https://yourapp.com",
            navigatorHostId = R.id.main_navigator_host
        )
    )
}
```

Update `res/layout/activity_main.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.fragment.app.FragmentContainerView
        android:id="@+id/main_navigator_host"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

### Step 5: Add Local Path Configuration

Create `app/src/main/assets/json/path-configuration.json`:

```json
{
  "settings": {
  },
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "presentation": "modal"
      }
    },
    {
      "patterns": ["/signup$", "/login$"],
      "properties": {
        "presentation": "modal"
      }
    }
  ]
}
```

### Step 6: Add Internet Permission

In `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Step 7: Test Locally

For local development, update `startLocation` to:
```kotlin
startLocation = "http://10.0.2.2:3000"  // Android emulator
// or "http://192.168.1.x:3000"         // Physical device
```

Run your Rails server with bind to all interfaces:
```bash
bin/rails server -b 0.0.0.0
```

Build and run the Android app in Android Studio emulator.

### Estimated Time

- **Initial setup**: 4-8 hours (first time)
- **Testing**: 2-4 hours
- **Play Store prep**: 4-8 hours
- **Total**: 10-20 hours

---

## Authentication

Your cookie-based authentication system works automatically with Hotwire Native!

- **iOS**: WKWebView shares cookies with the iOS system
- **Android**: WebView maintains session cookies

No additional configuration needed. When users log in through the mobile app, they'll stay logged in just like on the web.

---

## Customizing Navigation

### Path Configuration Rules

The path configuration JSON controls how screens are presented:

```json
{
  "rules": [
    {
      "patterns": ["/users/*/edit$"],
      "properties": {
        "presentation": "modal",
        "context": "modal"
      }
    },
    {
      "patterns": ["^/$"],
      "properties": {
        "presentation": "replace"
      }
    }
  ]
}
```

**Presentation options:**
- `default` - Standard navigation push
- `modal` - Present as modal
- `replace` - Replace current screen
- `refresh` - Refresh current screen
- `clear` - Clear navigation stack

### Updating Path Configuration

You can update navigation rules in two ways:

1. **Server-side** (recommended): Update the controller in `app/controllers/turbo/ios/path_configurations_controller.rb`
2. **Client-side**: Update `path-configuration.json` in the mobile app (requires app update)

The server configuration takes precedence and allows changes without app store updates!

---

## Bridge Components (Advanced)

Bridge Components let you add native UI elements that respond to HTML:

**Example use cases:**
- Native tab bars
- Native navigation buttons
- Native menus
- Native form controls
- Native alerts

**Structure:**
1. Stimulus controller (JavaScript) - Rails side
2. Swift component - iOS side
3. Kotlin component - Android side

**Example Stimulus controller:**
```javascript
import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "menu"

  connect() {
    this.send("connect", { title: "Menu" }, () => {
      // Optional callback
    })
  }
}
```

See the [Hotwire Native Bridge Components documentation](https://native.hotwired.dev/reference/bridge-components) for more details.

---

## Testing Strategy

### Rails Backend Tests

Tests are already written for the path configuration endpoints:

```bash
bin/rails test test/controllers/turbo/ios/path_configurations_controller_test.rb
bin/rails test test/controllers/turbo/android/path_configurations_controller_test.rb
bin/rails test test/controllers/concerns/turbo_native_detection_test.rb
```

### iOS Tests

Use XCTest for unit tests:
```swift
import XCTest
@testable import YourApp

class NavigationTests: XCTestCase {
    func testRootURLIsConfigured() {
        XCTAssertNotNil(SceneDelegate().rootURL)
    }
}
```

### Android Tests

Use JUnit for unit tests:
```kotlin
import org.junit.Test
import org.junit.Assert.*

class NavigationTest {
    @Test
    fun testStartLocationIsConfigured() {
        val activity = MainActivity()
        val config = activity.navigatorConfigurations().first()
        assertNotNull(config.startLocation)
    }
}
```

### Manual Testing Checklist

- [ ] App launches and loads homepage
- [ ] Navigation works (clicking links)
- [ ] Back button works correctly
- [ ] Authentication flow (login/logout)
- [ ] Modal presentation (signup, login)
- [ ] Form submissions work
- [ ] Pull-to-refresh works
- [ ] Offline handling (connection errors)

---

## Deployment

### iOS App Store

1. **Create App Store listing** in App Store Connect
2. **Configure app bundle identifier** in Xcode
3. **Create signing certificates** (Apple Developer account required)
4. **Archive and submit** via Xcode
5. **TestFlight beta testing** (recommended before public release)
6. **Submit for review** (typically 1-3 days)

**Resources:**
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

### Android Play Store

1. **Create Play Console account** ($25 one-time fee)
2. **Create app listing** in Play Console
3. **Generate signed APK/AAB** in Android Studio
4. **Internal testing** (recommended first)
5. **Open/closed testing** (optional beta)
6. **Production release** (review typically < 24 hours)

**Resources:**
- [Launch your app on Google Play](https://developer.android.com/distribute/best-practices/launch)
- [Prepare and roll out releases](https://support.google.com/googleplay/android-developer/answer/9859348)

### Update Workflow

When you update your Rails app:

1. **Web-only changes**: Deploy normally with Kamal (no app updates needed!)
2. **Navigation changes**: Update path configuration endpoint (no app updates needed!)
3. **New native features**: Update mobile apps and submit to stores

This is the power of Hotwire Native - most changes don't require app store updates!

---

## Troubleshooting

### iOS Issues

**"Cannot connect to localhost"**
- Ensure Rails server is running: `bin/dev`
- Check `rootURL` in `SceneDelegate.swift`
- For simulator, `http://localhost:3000` works
- For device, use your Mac's IP address

**"Failed to load path configuration"**
- Check `path-configuration.json` is added to Xcode project
- Verify JSON syntax is valid
- Check server endpoint returns valid JSON

### Android Issues

**"Cannot connect to localhost"**
- Use `http://10.0.2.2:3000` for emulator (maps to host machine)
- Use `http://192.168.1.x:3000` for physical device
- Ensure Rails server binds to all interfaces: `bin/rails server -b 0.0.0.0`

**"Cleartext HTTP not permitted"**
- Add network security configuration for development
- See `AndroidManifest.xml` configuration above

### General Issues

**Authentication not persisting**
- Check cookies are being set correctly
- Verify `SameSite` cookie attribute (should be `:lax` for mobile)
- Check `ApplicationController` includes `Authentication` concern

**Blank screen on app launch**
- Check Rails server is running and accessible
- Check network permissions (Android)
- Check App Transport Security (iOS)
- Look for JavaScript errors in web inspector

---

## Next Steps

1. **Test the backend** - Run the Rails tests to ensure everything works
2. **Choose a platform** - Start with iOS or Android (iOS is typically easier)
3. **Build basic app** - Follow the platform guide above
4. **Test authentication** - Ensure login/logout works
5. **Customize navigation** - Update path configuration for your needs
6. **Add bridge components** - Enhance with native UI elements (optional)
7. **Beta test** - TestFlight (iOS) or Internal Testing (Android)
8. **Submit to stores** - Follow deployment guides above

---

## Resources

### Official Documentation
- [Hotwire Native Documentation](https://native.hotwired.dev/)
- [Hotwire Native iOS GitHub](https://github.com/hotwired/hotwire-native-ios)
- [Hotwire Native Android GitHub](https://github.com/hotwired/hotwire-native-android)

### Tutorials
- [William Kennedy's iOS Tutorial Series](https://williamkennedy.ninja/hotwire-native/)
- [William Kennedy's Android Tutorial Series](https://williamkennedy.ninja/hotwire-native/2024/12/23/up-and-running-with-hotwire-android-1-setup/)
- [Joe Masilotti - Turbo Native in 15 Minutes](https://masilotti.com/turbo-native-apps-in-15-minutes/)

### Books
- [Hotwire Native for Rails Developers (PragProg)](https://pragprog.com/titles/jmnative/hotwire-native-for-rails-developers/)

### Community
- [Hotwire Discussions](https://github.com/hotwired/hotwire-rails/discussions)
- [Joe Masilotti's Blog](https://masilotti.com/)
- [Bridge Components Library](https://github.com/joemasilotti/bridge-components)

---

## Philosophy Alignment

Hotwire Native fits perfectly with the Rails Starter Template philosophy:

✅ **Pure Rails approach** - Reuse existing HTML/CSS/JavaScript
✅ **No external services** - Native apps connect directly to your Rails server
✅ **SQLite for everything** - Auth, sessions, cache all work as-is
✅ **Minimal dependencies** - Native frameworks are self-contained
✅ **Operational simplicity** - One Rails backend serves web + mobile
✅ **Lower costs** - No separate mobile API backend needed
✅ **Faster deployments** - Most changes don't require app updates
✅ **Easier debugging** - Single source of truth (Rails views)

**Build once, deploy everywhere. That's the Hotwire Native way.**

# GoogleSignInKit

[![CI](https://github.com/rouzbeh-abadi/GoogleSignInKit/actions/workflows/ci.yml/badge.svg)](https://github.com/rouzbeh-abadi/GoogleSignInKit/actions/workflows/ci.yml)

A small Swift package that wraps Google's official [GoogleSignIn-iOS](https://github.com/google/GoogleSignIn-iOS) SDK behind a strongly typed, async/await friendly API.

It removes the boilerplate of configuring `GIDSignIn` and parsing `GIDSignInResult`, and exposes a coordinator that is API parallel to [AppleSignInKit](https://github.com/rouzbeh-abadi/AppleSignInKit), so a host app can adopt both with one mental model.

## Features

- Sign in, restore previous sign in, sign out, and disconnect
- async/await **and** closure based APIs
- Strongly typed `GoogleSignInResult` value type, safe to pass across queues
- Strongly typed `GoogleSignInError` enum with `LocalizedError` descriptions
- One liner URL callback handling for the host app delegate or SwiftUI scene
- Drop in `GoogleSignInButton` (UIKit) and `GoogleSignInButtonView` (SwiftUI), so host apps do not need to `import GoogleSignIn` for the button
- `GoogleSignInButtonModern` (UIKit) and `GoogleSignInButtonModernView` (SwiftUI), a custom built button that scales with caller specified height and offers light, dark, and neutral color schemes
- A single, well known dependency on `GoogleSignIn-iOS`

## Requirements

| Platform   | Minimum |
| ---------- | ------- |
| iOS        | 13.0    |
| Mac Catalyst | 13.0  |
| Swift      | 5.9     |
| Xcode      | 15      |

## Installation

### Swift Package Manager

In Xcode: **File > Add Package Dependencies**, then enter the repository URL.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-account>/GoogleSignInKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: ["GoogleSignInKit"]
    )
]
```

## Project setup

The host app needs three things before sign in will work:

1. An **OAuth 2.0 client ID for iOS** from the [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. The **reversed client ID** registered as a custom URL scheme in `Info.plist`. Example:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

3. A **URL forwarder** so the SDK can complete the sign in flow when control returns to your app.

### URL forwarder, UIKit

```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    GoogleSignInCoordinator.handle(openURL: url)
}
```

### URL forwarder, SwiftUI

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GoogleSignInCoordinator.handle(openURL: url)
                }
        }
    }
}
```

## Usage

### Quick start (UIKit)

```swift
import UIKit
import GoogleSignInKit

final class LoginViewController: UIViewController {

    private let coordinator = GoogleSignInCoordinator(
        clientID: "YOUR_CLIENT_ID.apps.googleusercontent.com"
    )

    @IBAction private func signIn() {
        coordinator.signIn(from: self) { [weak self] result in
            switch result {
            case .success(let user):
                print("Signed in:", user.email ?? user.userID)
                print("Identity token bytes:", user.idToken?.count ?? 0)
            case .failure(let error):
                print("Sign in failed:", error.localizedDescription)
            }
        }
    }
}
```

### Quick start (SwiftUI)

```swift
import SwiftUI
import GoogleSignInKit

struct LoginView: View {

    @State private var status = "Not signed in"

    private let coordinator = GoogleSignInCoordinator(
        clientID: "YOUR_CLIENT_ID.apps.googleusercontent.com"
    )

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
            Button("Sign in with Google", action: signIn)
        }
        .padding()
    }

    private func signIn() {
        guard let presenter = UIApplication.shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else { return }

        Task {
            do {
                let user = try await coordinator.signIn(from: presenter)
                status = "Signed in as \(user.email ?? user.userID)"
            } catch {
                status = "Failed: \(error.localizedDescription)"
            }
        }
    }
}
```

### Using the built in button

Google's official sign in button is re exported under cleaner names so the host app does not need to `import GoogleSignIn`.

UIKit:

```swift
import GoogleSignInKit

let button = GoogleSignInButton()
button.style = .wide          // .standard, .wide, .iconOnly
button.colorScheme = .light   // .light, .dark
button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
loginProviderStackView.addArrangedSubview(button)
```

SwiftUI:

```swift
import GoogleSignInKit

GoogleSignInButtonView(style: .wide, colorScheme: .light) {
    coordinator.signIn(from: presenter) { result in
        // handle result
    }
}
.frame(height: 44)
```

### Modern, height scalable button

`GoogleSignInButton` is a typealias of Google's older `GIDSignInButton`, which has a baked in size and ignores caller specified heights. When you need a button that follows your design system (taller, custom corner radius, etc.), use `GoogleSignInButtonModern` instead. It is laid out with Auto Layout and scales with whatever height you give it.

For wide variants (`.signIn`, `.signUp`, `.continueWith`) the Google "G" mark is **not bundled**. Download the official asset from [Google's brand guidelines](https://developers.google.com/identity/branding-guidelines) and supply it via `logoImage`. Without an image the button renders text only.

For `.iconOnly` the package bundles Google's official square sign in SVGs (neutral and dark variants) and auto picks the right one based on `colorScheme`. No extra setup required.

UIKit, wide button:

```swift
import GoogleSignInKit

let button = GoogleSignInButtonModern()
button.colorScheme = .light                   // .light, .dark, .neutral
button.textVariant = .signIn                  // .signIn, .signUp, .continueWith
button.cornerRadius = 12
button.logoImage = UIImage(named: "GoogleG")  // your asset
button.heightAnchor.constraint(equalToConstant: 56).isActive = true
button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
loginProviderStackView.addArrangedSubview(button)
```

UIKit, official icon only button (uses bundled SVGs, no `logoImage` needed):

```swift
import GoogleSignInKit

let button = GoogleSignInButtonModern()
button.textVariant = .iconOnly
button.colorScheme = .dark        // bundled dark SVG, switch to .light for the neutral SVG
button.heightAnchor.constraint(equalToConstant: 56).isActive = true
button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
```

SwiftUI:

```swift
import GoogleSignInKit

GoogleSignInButtonModernView(colorScheme: .light,
                             textVariant: .signIn,
                             logoImage: UIImage(named: "GoogleG"),
                             cornerRadius: 12) {
    coordinator.signIn(from: presenter) { result in
        // handle result
    }
}
.frame(height: 56)
```

### Restoring a previous sign in on launch

```swift
do {
    let user = try await coordinator.restorePreviousSignIn()
    showHome(for: user)
} catch GoogleSignInError.noPreviousSignIn {
    showLogin()
} catch {
    showLogin()
}
```

### Requesting additional OAuth scopes

```swift
let user = try await coordinator.signIn(
    from: presenter,
    additionalScopes: ["https://www.googleapis.com/auth/calendar.readonly"]
)
```

### Server side flow

Pass a `serverClientID` and forward `serverAuthCode` to your backend:

```swift
let coordinator = GoogleSignInCoordinator(
    clientID: "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com",
    serverClientID: "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"
)

let user = try await coordinator.signIn(from: presenter)
if let serverAuthCode = user.serverAuthCode {
    // POST { code: serverAuthCode } to your backend.
}
```

### Signing out and disconnecting

```swift
coordinator.signOut()                    // clears local state, can be silently restored
try await coordinator.disconnect()       // also revokes tokens server side
```

## Public API

| Type | Purpose |
|---|---|
| `GoogleSignInCoordinator` | Configures Google Sign In and performs sign in, restore, sign out, and disconnect. |
| `GoogleSignInResult` | Value type snapshot of the signed in Google user. |
| `GoogleSignInError` | Strongly typed errors mapped from `GIDSignInError`. |
| `GoogleSignInButton` | UIKit sign in button (typealias of `GIDSignInButton`). |
| `GoogleSignInButtonStyle`, `GoogleSignInButtonColorScheme` | Button style and color scheme typealiases. |
| `GoogleSignInButtonView` | SwiftUI wrapper around `GoogleSignInButton` with a tap closure. |
| `GoogleSignInButtonModern` | UIKit custom built button. Auto Layout friendly, scales with caller specified height. Configurable color scheme, text variant, corner radius, and logo image. |
| `GoogleSignInButtonModernView` | SwiftUI wrapper around `GoogleSignInButtonModern`. |

## Testing

Because the underlying SDK is iOS only, run tests via Xcode:

```bash
xcodebuild test \
  -scheme GoogleSignInKit \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests cover the value type, the error mapping (every `GIDSignInError.Code`), and `LocalizedError` descriptions. They do not invoke the live Google sign in flow.

## License

[MIT](LICENSE).

## Author

Rouzbeh Abadi

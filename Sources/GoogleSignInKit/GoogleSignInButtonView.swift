//
//  GoogleSignInButtonView.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import SwiftUI
import GoogleSignIn

/// SwiftUI wrapper around Google's official UIKit sign in button.
///
/// Pass a closure to be invoked on tap. The button reflects ``style`` and
/// ``colorScheme`` updates from SwiftUI state.
///
/// ```swift
/// GoogleSignInButtonView(style: .wide, colorScheme: .light) {
///     coordinator.signIn(from: presenter) { ... }
/// }
/// .frame(height: 44)
/// ```
public struct GoogleSignInButtonView: UIViewRepresentable {

    private let style: GoogleSignInButtonStyle
    private let colorScheme: GoogleSignInButtonColorScheme
    private let action: () -> Void

    public init(style: GoogleSignInButtonStyle = .standard,
                colorScheme: GoogleSignInButtonColorScheme = .light,
                action: @escaping () -> Void) {
        self.style = style
        self.colorScheme = colorScheme
        self.action = action
    }

    public func makeUIView(context: Context) -> GoogleSignInButton {
        let button = GoogleSignInButton()
        button.style = style
        button.colorScheme = colorScheme
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.didTap),
                         for: .touchUpInside)
        return button
    }

    public func updateUIView(_ uiView: GoogleSignInButton, context: Context) {
        uiView.style = style
        uiView.colorScheme = colorScheme
        context.coordinator.action = action
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTap() {
            action()
        }
    }
}

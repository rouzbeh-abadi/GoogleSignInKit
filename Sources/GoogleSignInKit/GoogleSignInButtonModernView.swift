//
//  GoogleSignInButtonModernView.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper around ``GoogleSignInButtonModern``.
///
/// Unlike ``GoogleSignInButtonView`` (which inherits a fixed intrinsic size
/// from `GIDSignInButton`), this view scales to whatever frame SwiftUI gives
/// it. Combine with `.frame(height:)` to get the size you want.
///
/// ```swift
/// GoogleSignInButtonModernView(colorScheme: .light, textVariant: .signIn) {
///     coordinator.signIn(from: presenter) { ... }
/// }
/// .frame(height: 56)
/// ```
public struct GoogleSignInButtonModernView: UIViewRepresentable {

    private let colorScheme: GoogleSignInButtonModern.ColorScheme
    private let textVariant: GoogleSignInButtonModern.TextVariant
    private let logoImage: UIImage?
    private let cornerRadius: CGFloat
    private let action: () -> Void

    public init(colorScheme: GoogleSignInButtonModern.ColorScheme = .light,
                textVariant: GoogleSignInButtonModern.TextVariant = .signIn,
                logoImage: UIImage? = nil,
                cornerRadius: CGFloat = 8,
                action: @escaping () -> Void) {
        self.colorScheme = colorScheme
        self.textVariant = textVariant
        self.logoImage = logoImage
        self.cornerRadius = cornerRadius
        self.action = action
    }

    public func makeUIView(context: Context) -> GoogleSignInButtonModern {
        let button = GoogleSignInButtonModern()
        button.colorScheme = colorScheme
        button.textVariant = textVariant
        button.logoImage = logoImage
        button.cornerRadius = cornerRadius
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.didTap),
                         for: .touchUpInside)
        return button
    }

    public func updateUIView(_ uiView: GoogleSignInButtonModern, context: Context) {
        uiView.colorScheme = colorScheme
        uiView.textVariant = textVariant
        uiView.logoImage = logoImage
        uiView.cornerRadius = cornerRadius
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

//
//  GoogleSignInButtonTests.swift
//  GoogleSignInKitTests
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import XCTest
import SwiftUI
@testable import GoogleSignInKit

final class GoogleSignInButtonTests: XCTestCase {

    // MARK: UIKit button

    func testButtonInstantiates() {
        let button = GoogleSignInButton()
        XCTAssertNotNil(button)
    }

    func testButtonStyleRoundTrip() {
        let button = GoogleSignInButton()

        button.style = .standard
        XCTAssertEqual(button.style, .standard)

        button.style = .wide
        XCTAssertEqual(button.style, .wide)

        button.style = .iconOnly
        XCTAssertEqual(button.style, .iconOnly)
    }

    func testButtonColorSchemeRoundTrip() {
        let button = GoogleSignInButton()

        button.colorScheme = .light
        XCTAssertEqual(button.colorScheme, .light)

        button.colorScheme = .dark
        XCTAssertEqual(button.colorScheme, .dark)
    }

    func testButtonAcceptsExternalTarget() {
        let button = GoogleSignInButton()
        let countBefore = button.allTargets.count
        button.addTarget(self, action: #selector(noop), for: .touchUpInside)
        XCTAssertEqual(button.allTargets.count, countBefore + 1)
        XCTAssertTrue(button.allTargets.contains(self))
    }

    @objc private func noop() {}

    // MARK: SwiftUI button

    // SwiftUI's UIViewRepresentable.Context has no public initializer, so we
    // can only exercise the parts of the SwiftUI wrapper that do not require
    // one (the Coordinator). Compilation of `GoogleSignInButtonView` itself is
    // the integration test for `makeUIView` / `updateUIView`.

    func testSwiftUIViewCoordinatorInvokesActionOnTap() {
        var tapped = 0
        let view = GoogleSignInButtonView(style: .wide, colorScheme: .dark) {
            tapped += 1
        }
        let coordinator = view.makeCoordinator()
        coordinator.didTap()
        coordinator.didTap()
        coordinator.didTap()
        XCTAssertEqual(tapped, 3)
    }

    func testSwiftUIViewCoordinatorActionCanBeReplaced() {
        var firstActionCount = 0
        var secondActionCount = 0

        let view = GoogleSignInButtonView { firstActionCount += 1 }
        let coordinator = view.makeCoordinator()

        coordinator.didTap()
        XCTAssertEqual(firstActionCount, 1)
        XCTAssertEqual(secondActionCount, 0)

        coordinator.action = { secondActionCount += 1 }
        coordinator.didTap()
        XCTAssertEqual(firstActionCount, 1)
        XCTAssertEqual(secondActionCount, 1)
    }
}

//
//  GoogleSignInButtonModernTests.swift
//  GoogleSignInKitTests
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import XCTest
import UIKit
@testable import GoogleSignInKit

final class GoogleSignInButtonModernTests: XCTestCase {

    // MARK: UIKit button

    func testInstantiates() {
        let button = GoogleSignInButtonModern()
        XCTAssertNotNil(button)
    }

    func testDefaultColorSchemeIsLight() {
        let button = GoogleSignInButtonModern()
        XCTAssertEqual(button.colorScheme, .light)
    }

    func testDefaultTextVariantIsSignIn() {
        let button = GoogleSignInButtonModern()
        XCTAssertEqual(button.textVariant, .signIn)
    }

    func testColorSchemeRoundTrip() {
        let button = GoogleSignInButtonModern()
        for value: GoogleSignInButtonModern.ColorScheme in [.light, .dark, .neutral] {
            button.colorScheme = value
            XCTAssertEqual(button.colorScheme, value)
        }
    }

    func testTextVariantRoundTrip() {
        let button = GoogleSignInButtonModern()
        for value: GoogleSignInButtonModern.TextVariant in [.signIn, .signUp, .continueWith] {
            button.textVariant = value
            XCTAssertEqual(button.textVariant, value)
        }
    }

    func testTextVariantTitles() {
        XCTAssertEqual(GoogleSignInButtonModern.TextVariant.signIn.localizedTitle,
                       "Sign in with Google")
        XCTAssertEqual(GoogleSignInButtonModern.TextVariant.signUp.localizedTitle,
                       "Sign up with Google")
        XCTAssertEqual(GoogleSignInButtonModern.TextVariant.continueWith.localizedTitle,
                       "Continue with Google")
    }

    func testCornerRadiusRoundTrip() {
        let button = GoogleSignInButtonModern()
        button.cornerRadius = 16
        XCTAssertEqual(button.cornerRadius, 16)
        XCTAssertEqual(button.layer.cornerRadius, 16)
    }

    func testLogoImageRoundTripAndIsHiddenWhenNil() {
        let button = GoogleSignInButtonModern()
        XCTAssertNil(button.logoImage)

        let image = UIImage(systemName: "g.circle.fill")
        button.logoImage = image
        XCTAssertNotNil(button.logoImage)

        button.logoImage = nil
        XCTAssertNil(button.logoImage)
    }

    func testRespectsHeightAnchor() {
        let button = GoogleSignInButtonModern()
        let parent = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        parent.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        parent.layoutIfNeeded()
        XCTAssertEqual(button.bounds.height, 60, accuracy: 0.01)
    }

    func testAcceptsExternalTarget() {
        let button = GoogleSignInButtonModern()
        let countBefore = button.allTargets.count
        button.addTarget(self, action: #selector(noop), for: .touchUpInside)
        XCTAssertEqual(button.allTargets.count, countBefore + 1)
        XCTAssertTrue(button.allTargets.contains(self))
    }

    @objc private func noop() {}

    // MARK: SwiftUI wrapper

    func testSwiftUIViewCoordinatorInvokesActionOnTap() {
        var taps = 0
        let view = GoogleSignInButtonModernView(colorScheme: .dark, textVariant: .signUp) {
            taps += 1
        }
        let coordinator = view.makeCoordinator()
        coordinator.didTap()
        coordinator.didTap()
        XCTAssertEqual(taps, 2)
    }

    func testSwiftUIViewCoordinatorActionCanBeReplaced() {
        var firstActionCount = 0
        var secondActionCount = 0

        let view = GoogleSignInButtonModernView { firstActionCount += 1 }
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

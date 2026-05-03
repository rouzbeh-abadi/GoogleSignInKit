//
//  GoogleSignInErrorTests.swift
//  GoogleSignInKitTests
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import XCTest
import GoogleSignIn
@testable import GoogleSignInKit

final class GoogleSignInErrorTests: XCTestCase {

    func testErrorDescriptionsAreNotEmpty() {
        let cases: [GoogleSignInError] = [
            .canceled,
            .noPreviousSignIn,
            .keychain,
            .scopesAlreadyGranted,
            .mismatchWithCurrentUser,
            .enterpriseMobilityManagement,
            .missingPresentingViewController,
            .unknown(underlying: nil),
            .unknown(underlying: NSError(domain: "Test", code: 42))
        ]
        for error in cases {
            XCTAssertNotNil(error.errorDescription, "Missing description for: \(error)")
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true,
                           "Empty description for: \(error)")
        }
    }

    func testEqualityForSimpleCases() {
        XCTAssertEqual(GoogleSignInError.canceled, GoogleSignInError.canceled)
        XCTAssertEqual(GoogleSignInError.noPreviousSignIn, GoogleSignInError.noPreviousSignIn)
        XCTAssertEqual(GoogleSignInError.keychain, GoogleSignInError.keychain)
        XCTAssertEqual(GoogleSignInError.missingPresentingViewController,
                       GoogleSignInError.missingPresentingViewController)
        XCTAssertNotEqual(GoogleSignInError.canceled, GoogleSignInError.keychain)
        XCTAssertNotEqual(GoogleSignInError.noPreviousSignIn, GoogleSignInError.canceled)
    }

    func testEqualityForUnknownWithUnderlyingError() {
        let nsError = NSError(domain: "Test", code: 1)
        XCTAssertEqual(
            GoogleSignInError.unknown(underlying: nsError),
            GoogleSignInError.unknown(underlying: nsError)
        )
        XCTAssertNotEqual(
            GoogleSignInError.unknown(underlying: nsError),
            GoogleSignInError.unknown(underlying: NSError(domain: "Other", code: 1))
        )
        XCTAssertEqual(
            GoogleSignInError.unknown(underlying: nil),
            GoogleSignInError.unknown(underlying: nil)
        )
    }

    func testMappingFromCanceled() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.canceled.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .canceled)
    }

    func testMappingFromNoAuthInKeychain() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.hasNoAuthInKeychain.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .noPreviousSignIn)
    }

    func testMappingFromKeychain() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.keychain.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .keychain)
    }

    func testMappingFromScopesAlreadyGranted() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.scopesAlreadyGranted.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .scopesAlreadyGranted)
    }

    func testMappingFromMismatchWithCurrentUser() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.mismatchWithCurrentUser.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .mismatchWithCurrentUser)
    }

    func testMappingFromEMM() {
        let error = NSError(domain: kGIDSignInErrorDomain,
                            code: GIDSignInError.Code.EMM.rawValue)
        XCTAssertEqual(GoogleSignInError(error: error), .enterpriseMobilityManagement)
    }

    func testMappingFromUnknownGIDCode() {
        let error = NSError(domain: kGIDSignInErrorDomain, code: 99999)
        if case .unknown(let underlying) = GoogleSignInError(error: error) {
            XCTAssertEqual((underlying as NSError?)?.domain, kGIDSignInErrorDomain)
            XCTAssertEqual((underlying as NSError?)?.code, 99999)
        } else {
            XCTFail("Expected .unknown for unmapped GID error code")
        }
    }

    func testMappingFromForeignDomain() {
        let foreign = NSError(domain: "SomeOtherDomain", code: 1)
        if case .unknown(let underlying) = GoogleSignInError(error: foreign) {
            XCTAssertEqual((underlying as NSError?)?.domain, "SomeOtherDomain")
        } else {
            XCTFail("Expected .unknown for foreign domain")
        }
    }

    func testUnknownDescriptionIncludesUnderlyingDescription() {
        let nsError = NSError(domain: "Test",
                              code: 7,
                              userInfo: [NSLocalizedDescriptionKey: "an underlying problem"])
        let error = GoogleSignInError.unknown(underlying: nsError)
        XCTAssertTrue(
            error.errorDescription?.contains("an underlying problem") ?? false,
            "Expected underlying description to be surfaced. Got: \(error.errorDescription ?? "nil")"
        )
    }
}

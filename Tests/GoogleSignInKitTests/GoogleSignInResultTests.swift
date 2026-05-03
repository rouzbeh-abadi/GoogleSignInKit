//
//  GoogleSignInResultTests.swift
//  GoogleSignInKitTests
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import XCTest
@testable import GoogleSignInKit

final class GoogleSignInResultTests: XCTestCase {

    func testMemberwiseInitializerStoresValues() {
        let result = GoogleSignInResult(
            userID: "abc123",
            name: "Ada Lovelace",
            givenName: "Ada",
            familyName: "Lovelace",
            email: "ada@example.com",
            profileImageURL: URL(string: "https://example.com/ada.jpg"),
            hasImage: true,
            idToken: "id-token",
            idTokenExpirationDate: Date(timeIntervalSince1970: 100),
            accessToken: "access-token",
            accessTokenExpirationDate: Date(timeIntervalSince1970: 200),
            refreshToken: "refresh-token",
            grantedScopes: ["email", "profile"],
            serverAuthCode: "server-auth-code"
        )
        XCTAssertEqual(result.userID, "abc123")
        XCTAssertEqual(result.name, "Ada Lovelace")
        XCTAssertEqual(result.givenName, "Ada")
        XCTAssertEqual(result.familyName, "Lovelace")
        XCTAssertEqual(result.email, "ada@example.com")
        XCTAssertEqual(result.profileImageURL?.absoluteString, "https://example.com/ada.jpg")
        XCTAssertTrue(result.hasImage)
        XCTAssertEqual(result.idToken, "id-token")
        XCTAssertEqual(result.idTokenExpirationDate, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(result.accessToken, "access-token")
        XCTAssertEqual(result.accessTokenExpirationDate, Date(timeIntervalSince1970: 200))
        XCTAssertEqual(result.refreshToken, "refresh-token")
        XCTAssertEqual(result.grantedScopes, ["email", "profile"])
        XCTAssertEqual(result.serverAuthCode, "server-auth-code")
    }

    func testDefaultValues() {
        let result = GoogleSignInResult(
            userID: "user",
            accessToken: "access",
            refreshToken: "refresh"
        )
        XCTAssertNil(result.name)
        XCTAssertNil(result.givenName)
        XCTAssertNil(result.familyName)
        XCTAssertNil(result.email)
        XCTAssertNil(result.profileImageURL)
        XCTAssertFalse(result.hasImage)
        XCTAssertNil(result.idToken)
        XCTAssertNil(result.idTokenExpirationDate)
        XCTAssertNil(result.accessTokenExpirationDate)
        XCTAssertEqual(result.grantedScopes, [])
        XCTAssertNil(result.serverAuthCode)
    }

    func testEqualityForIdenticalValues() {
        let lhs = GoogleSignInResult(userID: "u",
                                     accessToken: "a",
                                     refreshToken: "r",
                                     grantedScopes: ["scope"])
        let rhs = GoogleSignInResult(userID: "u",
                                     accessToken: "a",
                                     refreshToken: "r",
                                     grantedScopes: ["scope"])
        XCTAssertEqual(lhs, rhs)
    }

    func testInequalityWhenAnyFieldDiffers() {
        let base = GoogleSignInResult(userID: "u", accessToken: "a", refreshToken: "r")
        XCTAssertNotEqual(base,
                          GoogleSignInResult(userID: "different", accessToken: "a", refreshToken: "r"))
        XCTAssertNotEqual(base,
                          GoogleSignInResult(userID: "u", accessToken: "different", refreshToken: "r"))
        XCTAssertNotEqual(base,
                          GoogleSignInResult(userID: "u", accessToken: "a", refreshToken: "different"))
    }
}

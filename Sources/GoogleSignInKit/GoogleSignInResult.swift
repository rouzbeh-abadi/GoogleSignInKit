//
//  GoogleSignInResult.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import Foundation
import GoogleSignIn

/// A strongly typed snapshot of the data returned by a Google Sign In.
///
/// This is a value type copy of `GIDGoogleUser` (plus the optional
/// `serverAuthCode` from `GIDSignInResult`) so it can be safely passed across
/// queues, stored, or serialized for backend exchange.
public struct GoogleSignInResult: Equatable {

    /// The stable Google identifier for the user.
    public let userID: String

    /// The user's full display name. May be `nil` if the `profile` scope was
    /// not granted.
    public let name: String?

    /// The user's given name.
    public let givenName: String?

    /// The user's family name.
    public let familyName: String?

    /// The user's email. May be `nil` if the `email` scope was not granted.
    public let email: String?

    /// A URL pointing to a 200 pixel square version of the user's profile
    /// picture, or `nil` if the user has not set a picture.
    public let profileImageURL: URL?

    /// `true` when the user has set a profile picture.
    public let hasImage: Bool

    /// JSON Web Token used to verify the user identity on a backend.
    public let idToken: String?

    /// Expiration timestamp of ``idToken``.
    public let idTokenExpirationDate: Date?

    /// OAuth 2.0 access token, used to call Google APIs on the user's behalf.
    public let accessToken: String

    /// Expiration timestamp of ``accessToken``.
    public let accessTokenExpirationDate: Date?

    /// OAuth 2.0 refresh token. Used by the SDK to silently mint new access
    /// tokens. Generally you do not need to send this anywhere.
    public let refreshToken: String

    /// The OAuth scopes the user has granted to your app.
    public let grantedScopes: [String]

    /// Server auth code, present only when ``GoogleSignInCoordinator`` was
    /// configured with a `serverClientID`. Forward to your backend to exchange
    /// for refresh and access tokens server side.
    public let serverAuthCode: String?

    public init(signInResult: GIDSignInResult) {
        self.init(user: signInResult.user, serverAuthCode: signInResult.serverAuthCode)
    }

    public init(user: GIDGoogleUser, serverAuthCode: String?) {
        self.userID = user.userID ?? ""
        self.name = user.profile?.name
        self.givenName = user.profile?.givenName
        self.familyName = user.profile?.familyName
        self.email = user.profile?.email
        self.hasImage = user.profile?.hasImage ?? false
        self.profileImageURL = user.profile?.imageURL(withDimension: 200)
        self.idToken = user.idToken?.tokenString
        self.idTokenExpirationDate = user.idToken?.expirationDate
        self.accessToken = user.accessToken.tokenString
        self.accessTokenExpirationDate = user.accessToken.expirationDate
        self.refreshToken = user.refreshToken.tokenString
        self.grantedScopes = user.grantedScopes ?? []
        self.serverAuthCode = serverAuthCode
    }

    public init(userID: String,
                name: String? = nil,
                givenName: String? = nil,
                familyName: String? = nil,
                email: String? = nil,
                profileImageURL: URL? = nil,
                hasImage: Bool = false,
                idToken: String? = nil,
                idTokenExpirationDate: Date? = nil,
                accessToken: String,
                accessTokenExpirationDate: Date? = nil,
                refreshToken: String,
                grantedScopes: [String] = [],
                serverAuthCode: String? = nil) {
        self.userID = userID
        self.name = name
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.profileImageURL = profileImageURL
        self.hasImage = hasImage
        self.idToken = idToken
        self.idTokenExpirationDate = idTokenExpirationDate
        self.accessToken = accessToken
        self.accessTokenExpirationDate = accessTokenExpirationDate
        self.refreshToken = refreshToken
        self.grantedScopes = grantedScopes
        self.serverAuthCode = serverAuthCode
    }
}

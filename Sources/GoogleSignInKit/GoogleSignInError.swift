//
//  GoogleSignInError.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import Foundation
import GoogleSignIn

/// Errors produced by ``GoogleSignInCoordinator``.
public enum GoogleSignInError: Error, Equatable {

    /// The user canceled the sign in flow.
    case canceled

    /// No previous Google sign in is stored for this app.
    case noPreviousSignIn

    /// Reading or writing the keychain failed.
    case keychain

    /// The requested scopes were already granted, so no consent screen was
    /// shown. This is informational rather than fatal.
    case scopesAlreadyGranted

    /// A scope grant was attempted on behalf of a user that does not match the
    /// currently signed in user.
    case mismatchWithCurrentUser

    /// Sign in was blocked by Enterprise Mobility Management policies.
    case enterpriseMobilityManagement

    /// No presenting view controller was supplied to ``GoogleSignInCoordinator/signIn(from:hint:additionalScopes:completion:)``.
    case missingPresentingViewController

    /// An unmapped error returned by the SDK.
    case unknown(underlying: Error?)

    public init(error: Error) {
        let nsError = error as NSError
        guard nsError.domain == kGIDSignInErrorDomain else {
            self = .unknown(underlying: error)
            return
        }
        switch nsError.code {
        case GIDSignInError.Code.canceled.rawValue:
            self = .canceled
        case GIDSignInError.Code.hasNoAuthInKeychain.rawValue:
            self = .noPreviousSignIn
        case GIDSignInError.Code.keychain.rawValue:
            self = .keychain
        case GIDSignInError.Code.scopesAlreadyGranted.rawValue:
            self = .scopesAlreadyGranted
        case GIDSignInError.Code.mismatchWithCurrentUser.rawValue:
            self = .mismatchWithCurrentUser
        case GIDSignInError.Code.EMM.rawValue:
            self = .enterpriseMobilityManagement
        default:
            self = .unknown(underlying: error)
        }
    }

    public static func == (lhs: GoogleSignInError, rhs: GoogleSignInError) -> Bool {
        switch (lhs, rhs) {
        case (.canceled, .canceled),
             (.noPreviousSignIn, .noPreviousSignIn),
             (.keychain, .keychain),
             (.scopesAlreadyGranted, .scopesAlreadyGranted),
             (.mismatchWithCurrentUser, .mismatchWithCurrentUser),
             (.enterpriseMobilityManagement, .enterpriseMobilityManagement),
             (.missingPresentingViewController, .missingPresentingViewController):
            return true
        case let (.unknown(left), .unknown(right)):
            return (left as NSError?) == (right as NSError?)
        default:
            return false
        }
    }
}

extension GoogleSignInError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "Sign in was canceled by the user."
        case .noPreviousSignIn:
            return "No previous Google sign in was found."
        case .keychain:
            return "Sign in failed to read or write to the keychain."
        case .scopesAlreadyGranted:
            return "All requested scopes were already granted."
        case .mismatchWithCurrentUser:
            return "Sign in user does not match the currently signed in user."
        case .enterpriseMobilityManagement:
            return "Sign in was blocked by Enterprise Mobility Management policies."
        case .missingPresentingViewController:
            return "No presenting view controller was provided."
        case .unknown(let underlying):
            if let underlying = underlying {
                return "Sign in failed with an unknown error: \(underlying.localizedDescription)"
            }
            return "Sign in failed with an unknown error."
        }
    }
}

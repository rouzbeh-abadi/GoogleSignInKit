//
//  GoogleSignInCoordinator.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

/// Coordinates Google Sign In requests.
///
/// `GoogleSignInCoordinator` configures `GIDSignIn` and exposes a small,
/// strongly typed API to the caller. Construct one with your OAuth 2.0 client
/// ID, hold it for the lifetime of the screen that needs sign in, and call
/// ``signIn(from:hint:additionalScopes:completion:)``.
public final class GoogleSignInCoordinator {

    /// A closure invoked on the main queue when a sign in request finishes.
    public typealias CompletionHandler = (Result<GoogleSignInResult, GoogleSignInError>) -> Void

    /// Creates a coordinator and applies the configuration to the shared
    /// `GIDSignIn` instance.
    ///
    /// - Parameters:
    ///   - clientID: The OAuth 2.0 iOS client ID issued by the Google Cloud
    ///     Console.
    ///   - serverClientID: Optional OAuth 2.0 web client ID. When supplied,
    ///     the resulting ``GoogleSignInResult/serverAuthCode`` can be sent to
    ///     your backend in exchange for refresh and access tokens.
    ///   - hostedDomain: Optional Google Workspace domain. When supplied, only
    ///     accounts in that domain can sign in.
    ///   - openIDRealm: Optional OpenID 2.0 realm value for hybrid
    ///     deployments.
    public init(clientID: String,
                serverClientID: String? = nil,
                hostedDomain: String? = nil,
                openIDRealm: String? = nil) {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID,
            hostedDomain: hostedDomain,
            openIDRealm: openIDRealm
        )
    }

    /// Performs an interactive sign in.
    ///
    /// - Parameters:
    ///   - presenter: The view controller used to present the sign in sheet.
    ///   - hint: Optional account hint, typically a previously seen email.
    ///   - additionalScopes: Optional OAuth scopes beyond the defaults
    ///     (`profile`, `email`, `openid`).
    ///   - completion: Called on the main queue with the outcome.
    public func signIn(from presenter: UIViewController,
                       hint: String? = nil,
                       additionalScopes: [String]? = nil,
                       completion: @escaping CompletionHandler) {
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presenter,
            hint: hint,
            additionalScopes: additionalScopes
        ) { signInResult, error in
            Self.deliver(signInResult: signInResult, error: error, completion: completion)
        }
    }

    /// Restores a previously signed in user without showing UI.
    ///
    /// Call this from your app launch path so you can decide whether to keep
    /// the user signed in.
    ///
    /// - Parameter completion: Called on the main queue. Returns
    ///   ``GoogleSignInError/noPreviousSignIn`` when no stored user is found.
    public func restorePreviousSignIn(completion: @escaping CompletionHandler) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                Self.complete(.failure(GoogleSignInError(error: error)), completion: completion)
                return
            }
            guard let user = user else {
                Self.complete(.failure(.noPreviousSignIn), completion: completion)
                return
            }
            Self.complete(.success(GoogleSignInResult(user: user, serverAuthCode: nil)),
                          completion: completion)
        }
    }

    /// Clears the locally cached sign in state. The user remains authorized
    /// from Google's side and can be restored silently.
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    /// Revokes the user's authorization on Google's servers. After
    /// disconnecting, the user must complete the consent flow again on the
    /// next sign in.
    public func disconnect(completion: @escaping (Result<Void, GoogleSignInError>) -> Void) {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                Self.completeOnMain(.failure(GoogleSignInError(error: error)), completion: completion)
            } else {
                Self.completeOnMain(.success(()), completion: completion)
            }
        }
    }

    /// The currently signed in user, if any. Use this for fast, synchronous
    /// reads after launch has completed.
    public var currentUser: GoogleSignInResult? {
        guard let user = GIDSignIn.sharedInstance.currentUser else { return nil }
        return GoogleSignInResult(user: user, serverAuthCode: nil)
    }

    /// `true` when there is a stored sign in that ``restorePreviousSignIn(completion:)``
    /// can attempt to restore.
    public var hasPreviousSignIn: Bool {
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }

    /// Forwards a URL callback to Google's SDK so it can complete the sign in
    /// flow. Wire this into your `UIApplicationDelegate`'s `application(_:open:options:)`
    /// or your SwiftUI scene's `onOpenURL`.
    ///
    /// - Returns: `true` when the URL was handled by Google's SDK.
    @discardableResult
    public static func handle(openURL url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    private static func deliver(signInResult: GIDSignInResult?,
                                error: Error?,
                                completion: @escaping CompletionHandler) {
        if let error = error {
            complete(.failure(GoogleSignInError(error: error)), completion: completion)
            return
        }
        guard let signInResult = signInResult else {
            complete(.failure(.unknown(underlying: nil)), completion: completion)
            return
        }
        complete(.success(GoogleSignInResult(signInResult: signInResult)),
                 completion: completion)
    }

    private static func complete(_ result: Result<GoogleSignInResult, GoogleSignInError>,
                                 completion: @escaping CompletionHandler) {
        completeOnMain(result, completion: completion)
    }

    private static func completeOnMain<T>(_ value: T, completion: @escaping (T) -> Void) {
        if Thread.isMainThread {
            completion(value)
        } else {
            DispatchQueue.main.async { completion(value) }
        }
    }
}

public extension GoogleSignInCoordinator {

    /// async/await variant of ``signIn(from:hint:additionalScopes:completion:)``.
    func signIn(from presenter: UIViewController,
                hint: String? = nil,
                additionalScopes: [String]? = nil) async throws -> GoogleSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            signIn(from: presenter, hint: hint, additionalScopes: additionalScopes) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// async/await variant of ``restorePreviousSignIn(completion:)``.
    func restorePreviousSignIn() async throws -> GoogleSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            restorePreviousSignIn { result in
                continuation.resume(with: result)
            }
        }
    }

    /// async/await variant of ``disconnect(completion:)``.
    func disconnect() async throws {
        try await withCheckedThrowingContinuation { continuation in
            disconnect { result in
                continuation.resume(with: result)
            }
        }
    }
}

//
//  GoogleSignInButton.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import GoogleSignIn

/// Google's official UIKit sign in button, re exported under a name that fits
/// the rest of the package.
///
/// Use this so host apps do not need to `import GoogleSignIn` just to add a
/// button to their login screen:
///
/// ```swift
/// import GoogleSignInKit
///
/// let button = GoogleSignInButton()
/// button.style = .wide
/// button.colorScheme = .light
/// button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
/// ```
public typealias GoogleSignInButton = GIDSignInButton

/// Style options for ``GoogleSignInButton``.
///
/// - `.standard`: text label and Google "G" mark, regular width.
/// - `.wide`: same as `.standard` but stretched to fill available width.
/// - `.iconOnly`: square button showing only the Google "G" mark.
public typealias GoogleSignInButtonStyle = GIDSignInButtonStyle

/// Color scheme options for ``GoogleSignInButton``.
///
/// - `.light`: white background, dark text.
/// - `.dark`: dark background, light text.
public typealias GoogleSignInButtonColorScheme = GIDSignInButtonColorScheme

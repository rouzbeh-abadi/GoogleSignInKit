//
//  GoogleSignInButtonModern.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import UIKit

/// A custom built sign in button that follows the spirit of Google's current
/// brand guidelines.
///
/// Unlike ``GoogleSignInButton`` (which is a typealias of the older
/// `GIDSignInButton` and ignores caller specified heights), this button is
/// laid out with Auto Layout and scales with whatever height the host gives
/// it (set a `heightAnchor`, place it in a stack view, etc).
///
/// The package bundles Google's official sign in assets:
///
/// - For ``TextVariant/iconOnly``, the full square SVG (neutral or dark
///   based on ``colorScheme``) is rendered edge to edge.
/// - For wide variants (``TextVariant/signIn``, ``TextVariant/signUp``,
///   ``TextVariant/continueWith``), the multi color Google "G" mark is shown
///   on the leading edge automatically. No host setup required.
///
/// Setting ``logoImage`` overrides the bundled asset in either mode.
public final class GoogleSignInButtonModern: UIControl {

    /// Visual color scheme.
    public enum ColorScheme: Equatable {
        /// White background with a subtle border and dark text. Recommended on
        /// light surfaces.
        case light
        /// Dark background with light text and no border. Recommended on dark
        /// surfaces.
        case dark
        /// White background with no border. A flat alternative to `.light` for
        /// designs that already separate the button visually.
        case neutral
    }

    /// What the button shows.
    public enum TextVariant: Equatable {
        /// "Sign in with Google".
        case signIn
        /// "Sign up with Google".
        case signUp
        /// "Continue with Google".
        case continueWith
        /// Square icon only button using Google's bundled official asset. The
        /// asset is auto picked based on ``colorScheme`` (dark for `.dark`,
        /// neutral for `.light` and `.neutral`).
        case iconOnly

        var localizedTitle: String? {
            switch self {
            case .signIn:       return "Sign in with Google"
            case .signUp:       return "Sign up with Google"
            case .continueWith: return "Continue with Google"
            case .iconOnly:     return nil
            }
        }
    }

    /// The visual color scheme. Default is `.light`.
    public var colorScheme: ColorScheme = .light {
        didSet {
            applyAppearance()
            updateBundledIconIfNeeded()
        }
    }

    /// What the button displays. Default is `.signIn`.
    public var textVariant: TextVariant = .signIn {
        didSet {
            titleLabel.text = textVariant.localizedTitle
            applyLayoutMode()
            applyAppearance()
            updateBundledIconIfNeeded()
        }
    }

    /// Optional image rendered on the leading edge of the button (wide
    /// variants) or filling the full button (icon only variant). Setting this
    /// overrides the bundled asset.
    public var logoImage: UIImage? {
        didSet {
            customLogoImage = logoImage
            refreshLogoImageView()
        }
    }

    /// Corner radius of the button. Default is 8 points. Ignored when
    /// ``textVariant`` is ``TextVariant/iconOnly`` (the bundled SVG renders
    /// its own corners).
    public var cornerRadius: CGFloat = 8 {
        didSet {
            if textVariant != .iconOnly {
                layer.cornerRadius = cornerRadius
            }
        }
    }

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()

    private var customLogoImage: UIImage?

    private var wideConstraints: [NSLayoutConstraint] = []
    private var iconOnlyConstraints: [NSLayoutConstraint] = []
    private var logoSizeConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    public override var intrinsicContentSize: CGSize {
        if textVariant == .iconOnly {
            return CGSize(width: 44, height: 44)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if textVariant != .iconOnly {
            let logoSide = max(bounds.height * 0.5, 16)
            logoSizeConstraint?.constant = logoSide
            titleLabel.font = .systemFont(ofSize: max(bounds.height * 0.32, 13),
                                          weight: .medium)
        }
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.isHidden = true

        titleLabel.text = textVariant.localizedTitle
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 12
        contentStack.isUserInteractionEnabled = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(logoImageView)
        contentStack.addArrangedSubview(titleLabel)

        addSubview(contentStack)

        let logoSize = logoImageView.heightAnchor.constraint(equalToConstant: 22)
        logoSizeConstraint = logoSize

        wideConstraints = [
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor),
            logoSize
        ]

        iconOnlyConstraints = [
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(equalTo: heightAnchor)
        ]
        for constraint in iconOnlyConstraints where constraint.firstAnchor === widthAnchor {
            constraint.priority = .defaultHigh
        }

        layer.masksToBounds = true
        applyLayoutMode()
        applyAppearance()
        updateBundledIconIfNeeded()

        addTarget(self, action: #selector(handleHighlightDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(handleHighlightUp),
                  for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    private func applyLayoutMode() {
        switch textVariant {
        case .iconOnly:
            NSLayoutConstraint.deactivate(wideConstraints)
            NSLayoutConstraint.activate(iconOnlyConstraints)
            titleLabel.isHidden = true
            logoImageView.isHidden = false
        default:
            NSLayoutConstraint.deactivate(iconOnlyConstraints)
            NSLayoutConstraint.activate(wideConstraints)
            titleLabel.isHidden = false
            refreshLogoImageView()
        }
        invalidateIntrinsicContentSize()
    }

    private func applyAppearance() {
        if textVariant == .iconOnly {
            backgroundColor = .clear
            layer.borderWidth = 0
            layer.borderColor = nil
            layer.cornerRadius = 0
            return
        }
        layer.cornerRadius = cornerRadius
        switch colorScheme {
        case .light:
            backgroundColor = .white
            titleLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
            layer.borderWidth = 1
            layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).cgColor
        case .dark:
            backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
            titleLabel.textColor = .white
            layer.borderWidth = 0
            layer.borderColor = nil
        case .neutral:
            backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
            titleLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }

    private func updateBundledIconIfNeeded() {
        refreshLogoImageView()
    }

    private func refreshLogoImageView() {
        let image = customLogoImage ?? GoogleSignInButtonModern.bundledImage(for: textVariant,
                                                                             scheme: colorScheme)
        logoImageView.image = image
        logoImageView.isHidden = image == nil
    }

    private static func bundledImage(for variant: TextVariant,
                                     scheme: ColorScheme) -> UIImage? {
        let name: String
        switch variant {
        case .iconOnly:
            name = (scheme == .dark) ? "GoogleSignInIconDark" : "GoogleSignInIconNeutral"
        case .signIn, .signUp, .continueWith:
            name = "GoogleSignInLogo"
        }
        return UIImage(named: name, in: .module, compatibleWith: nil)
    }

    @objc private func handleHighlightDown() {
        UIView.animate(withDuration: 0.1) { self.alpha = 0.7 }
    }

    @objc private func handleHighlightUp() {
        UIView.animate(withDuration: 0.2) { self.alpha = 1.0 }
    }
}

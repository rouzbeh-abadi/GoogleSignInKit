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
/// The Google G mark is **not** bundled. Download Google's official asset
/// from <https://developers.google.com/identity/branding-guidelines> and
/// supply it via ``logoImage``. Without an image the button renders text only.
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

    /// The text shown to the right of the logo.
    public enum TextVariant: Equatable {
        /// "Sign in with Google".
        case signIn
        /// "Sign up with Google".
        case signUp
        /// "Continue with Google".
        case continueWith

        var localizedTitle: String {
            switch self {
            case .signIn:       return "Sign in with Google"
            case .signUp:       return "Sign up with Google"
            case .continueWith: return "Continue with Google"
            }
        }
    }

    /// The visual color scheme. Default is `.light`.
    public var colorScheme: ColorScheme = .light {
        didSet { applyAppearance() }
    }

    /// The text variant displayed inside the button. Default is `.signIn`.
    public var textVariant: TextVariant = .signIn {
        didSet { titleLabel.text = textVariant.localizedTitle }
    }

    /// Optional image rendered on the leading edge of the button. Supply
    /// Google's official "G" mark here. When `nil`, the button renders text
    /// only.
    public var logoImage: UIImage? {
        didSet {
            logoImageView.image = logoImage
            logoImageView.isHidden = logoImage == nil
        }
    }

    /// Corner radius of the button. Default is 8 points.
    public var cornerRadius: CGFloat = 8 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()
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
        CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let logoSide = max(bounds.height * 0.5, 16)
        logoSizeConstraint?.constant = logoSide
        titleLabel.font = .systemFont(ofSize: max(bounds.height * 0.32, 13),
                                      weight: .medium)
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

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor),
            logoSize
        ])

        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        applyAppearance()

        addTarget(self, action: #selector(handleHighlightDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(handleHighlightUp),
                  for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    private func applyAppearance() {
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

    @objc private func handleHighlightDown() {
        UIView.animate(withDuration: 0.1) { self.alpha = 0.7 }
    }

    @objc private func handleHighlightUp() {
        UIView.animate(withDuration: 0.2) { self.alpha = 1.0 }
    }
}

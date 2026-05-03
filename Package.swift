// swift-tools-version: 5.9
//
//  Package.swift
//  GoogleSignInKit
//
//  Created by Rouzbeh Abadi on 2026-05-03.
//  Copyright (c) 2026 Rouzbeh Abadi. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "GoogleSignInKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GoogleSignInKit",
            targets: ["GoogleSignInKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            from: "7.0.0"
        )
    ],
    targets: [
        .target(
            name: "GoogleSignInKit",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            path: "Sources/GoogleSignInKit",
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "GoogleSignInKitTests",
            dependencies: ["GoogleSignInKit"],
            path: "Tests/GoogleSignInKitTests"
        )
    ]
)

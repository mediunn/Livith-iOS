// swift-tools-version: 6.0
//
//  Package.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "LivithDesignSystem",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LivithDesignSystem",
            targets: ["LivithDesignSystem"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "LivithDesignSystem",
            dependencies: ["Kingfisher"],
            path: "Projects/DesignSystem/Sources",
            resources: [
                .process("../Resources")
            ]
        ),
    ]
)

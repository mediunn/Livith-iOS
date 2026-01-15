//
//  Project.swift
//  Widget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .widget,
    targets: [
        .make(
            target: .widget(.widget),
            product: .appExtension,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Livith Widget",
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                ]
            ]),
            entitlements: .file(path: "Resources/LivithWidget.entitlements"),
            dependencies: [
                .external(.livithDesignSystem),
            ]
        )
    ]
)

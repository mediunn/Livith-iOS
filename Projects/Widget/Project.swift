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
    settings: .environment,
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
                .designSystem(.designSystem),
                .core(.livithNetwork),
                .core(.livithFoundation),
                .core(.persistence),
            ],
            settings: .settings(
                base: ["CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES"]
            )
        )
    ]
)

//
//  Project.swift
//  SharedFeature
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .sharedFeature,
    targets: [
        .make(
            target: .sharedFeature(.nicknameEditFeature),
            product: .framework,
            dependencies: [
                .external(.livithDesignSystem),
                .core(.diContainer),
                .domain(.domain)
            ]
        ),
        .make(
            target: .sharedFeature(.nicknameEditFeatureTests),
            product: .unitTests,
            dependencies: [
                .sharedFeature(.nicknameEditFeature)
            ]
        )
    ]
)

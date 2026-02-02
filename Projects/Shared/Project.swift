//
//  Project.swift
//  Shared
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .shared,
    targets: [
        .make(
            target: .shared(.nicknameEditFeature),
            product: .framework,
            dependencies: [
                .designSystem(.designSystem),
                .core(.diContainer),
                .domain(.domain)
            ]
        ),
        .make(
            target: .shared(.nicknameEditFeatureTests),
            product: .unitTests,
            dependencies: [
                .shared(.nicknameEditFeature)
            ]
        ),
        .make(
            target: .shared(.preferenceFeature),
            product: .framework,
            dependencies: [
                .designSystem(.designSystem),
                .core(.diContainer),
                .domain(.domain)
            ]
        ),
        .make(
            target: .shared(.preferenceFeatureTests),
            product: .unitTests,
            dependencies: [
                .shared(.preferenceFeature)
            ]
        )
    ]
)

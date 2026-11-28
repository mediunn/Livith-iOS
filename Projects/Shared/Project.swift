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
            target: .shared(.designSystem),
            product: .framework,
            dependencies: [
                .external(.kingfisher)
            ]
        ),
        .make(
            target: .shared(.displaySupport),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.livithFoundation)
            ]
        ),
        .make(
            target: .shared(.displaySupportTests),
            product: .unitTests,
            dependencies: [
                .shared(.displaySupport)
            ]
        )
    ]
)

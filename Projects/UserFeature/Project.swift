//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .user,
    targets: [
        .make(
            target: .user(.userFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .sharedFeature(.nicknameEdit),
                .external(.livithDesignSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.livithNetwork),
                .core(.persistence)
            ]
        )
    ]
)

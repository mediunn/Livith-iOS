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
                .shared(.nicknameEditFeature),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.livithNetwork),
                .core(.persistence),
                .shared(.preferenceFeature)
            ]
        )
    ]
)

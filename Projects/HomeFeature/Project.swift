//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .home,
    targets: [
        .make(
            target: .home(.homeFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .concert(.concertFeature),
                .user(.userFeature),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation)
            ]
        )
    ]
)

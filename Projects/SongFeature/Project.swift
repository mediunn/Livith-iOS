//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .song,
    targets: [
        .make(
            target: .song(.songFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .external(.youTubePlayerKit)
            ]
        )
    ]
)

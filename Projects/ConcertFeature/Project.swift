//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .concert,
    targets: [
        .make(
            target: .concert(.concertFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .setlist(.setlistFeature),
                .song(.songFeature),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.persistence)
            ]
        )
    ]
)

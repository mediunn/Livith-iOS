//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .setlist,
    targets: [
        .make(
            target: .setlist(.setlistFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.amplitude)
            ]
        )
    ]
)

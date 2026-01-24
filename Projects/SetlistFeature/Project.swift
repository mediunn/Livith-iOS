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
                .external(.livithDesignSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation)
            ]
        )
    ]
)

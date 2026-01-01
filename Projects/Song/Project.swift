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
            target: .song(.songData),
            product: .framework,
            dependencies: [
                .song(.songDomain),
                .core(.livithNetwork)
            ]
        ),
        .make(
            target: .song(.songDomain),
            product: .framework
        ),
        .make(
            target: .song(.songFeature),
            product: .framework,
            dependencies: [
                .song(.songDomain),
                .dsKit(),
                .core(.diContainer),
                .core(.livithConcurrency),
                .external(.youTubePlayerKit)
            ]
        )
    ]
)

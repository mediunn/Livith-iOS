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
            target: .setlist(.setlistData),
            product: .framework,
            dependencies: [
                .setlist(.setlistDomain),
                .core(.livithNetwork),
                .core(.diContainer)
            ]
        ),
        .make(
            target: .setlist(.setlistDomain),
            product: .framework
        ),
        .make(
            target: .setlist(.setlistFeature),
            product: .framework,
            dependencies: [
                .setlist(.setlistDomain),
                .dsKit(),
                .core(.diContainer),
                .core(.livithFoundation)
            ]
        )
    ]
)

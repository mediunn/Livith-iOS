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
            target: .user(.userData),
            product: .framework,
            dependencies: [
                .user(.userDomain),
                .core(.livithNetwork),
                .core(.diContainer),
                .core(.persistence)
            ]
        ),
        .make(
            target: .user(.userDomain),
            product: .framework
        ),
        .make(
            target: .user(.userFeature),
            product: .framework,
            dependencies: [
                .user(.userDomain),
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

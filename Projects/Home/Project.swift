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
            target: .home(.homeData),
            product: .framework,
            dependencies: [
                .home(.homeDomain),
                .core(.livithNetwork),
                .core(.diContainer)
            ]
        ),
        .make(
            target: .home(.homeDomain),
            product: .framework
        ),
        .make(
            target: .home(.homeFeature),
            product: .framework,
            dependencies: [
                .home(.homeDomain),
                .dsKit(),
                .core(.diContainer),
                .core(.livithConcurrency)
            ]
        )
    ]
)

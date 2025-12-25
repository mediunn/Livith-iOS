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
            target: .concert(.concertData),
            product: .framework,
            dependencies: [
                .concert(.concertDomain),
                .core(.livithNetwork)
            ]
        ),
        .make(
            target: .concert(.concertDomain),
            product: .framework
        ),
        .make(
            target: .concert(.concertFeature),
            product: .framework,
            dependencies: [
                .concert(.concertDomain),
                .dsKit(),
                .core(.diContainer),
                .core(.livithConcurrency)
            ]
        )
    ]
)

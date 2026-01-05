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
                .core(.diContainer),
                .core(.livithNetwork),
                .core(.livithFoundation)
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
                .setlist(.setlistFeature),
                .song(.songFeature),
                .dsKit(),
                .core(.diContainer),
                .core(.livithConcurrency),
                .core(.livithFoundation)
            ]
        ),
        .make(
            target: .concert(.concertTests),
            product: .unitTests,
            dependencies: [
                .concert(.concertData),
                .concert(.concertDomain),
                .core(.livithNetwork)
            ]
        )
    ]
)

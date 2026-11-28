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
            target: .home(.homeFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .concert(.concertFeature),
                .share(.shareFeature),
                .user(.userFeature),
                .designSystem(.designSystem),
                .shared(.concertSearch),
                .shared(.displaySupport),
                .shared(.nicknameEditFeature),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.amplitude)
            ]
        ),
        .make(
            target: .home(.homeFeatureTests),
            product: .unitTests,
            dependencies: [
                .home(.homeFeature),
                .shared(.nicknameEditFeature),
                .shared(.displaySupport)
            ]
        )
    ]
)

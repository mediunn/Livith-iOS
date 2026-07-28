//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .share,
    targets: [
        .make(
            target: .share(.shareFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .designSystem(.designSystem),
                .core(.diContainer),
                .core(.amplitude)
            ]
        ),
        .make(
            target: .share(.shareFeatureTests),
            product: .unitTests,
            dependencies: [
                .share(.shareFeature)
            ]
        )
    ]
)

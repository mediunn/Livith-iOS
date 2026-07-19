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
                .designSystem(.designSystem)
            ]
        )
    ]
)

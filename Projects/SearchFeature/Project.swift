//
//  Project.swift
//  Manifests
//
//  Created by Youjin Lee on 11/2/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .search,
    targets: [
        .make(
            target: .search(.searchFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .concert(.concertFeature),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.amplitude)
            ]
        )
    ]
)

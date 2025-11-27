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
            target: .search(.searchData),
            product: .framework,
            dependencies: [
                .search(.searchDomain),
                .core(.livithNetwork)
            ]
        ),
        .make(
            target: .search(.searchDomain),
            product: .framework
        ),
        .make(
            target: .search(.searchFeature),
            product: .framework,
            dependencies: [
                .search(.searchDomain),
                .shared(.designSystem),
                .core(.diContainer),
                .core(.livithConcurrency)
            ]
        )
    ]
)

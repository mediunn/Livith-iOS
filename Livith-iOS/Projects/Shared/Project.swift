//
//  Project.swift
//  AppManifests
//
//  Created by 김진웅 on 10/17/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .shared,
    targets: [
        .make(
            target: .shared(.designSystem),
            product: .framework,
            dependencies: [
                .external(.kingfisher)
            ]
        )
    ]
)

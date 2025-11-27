//
//  Project.swift
//  AppManifests
//
//  Created by 김진웅 on 10/17/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .dsKit,
    targets: [
        .make(
            target: .dsKit,
            product: .framework,
            dependencies: [
                .external(.kingfisher)
            ]
        )
    ]
)

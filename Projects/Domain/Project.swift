//
//  Project.swift
//  Manifests
//
//  Created by 김진웅 on 1/21/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .domain,
    targets: [
        .make(
            target: .domain(.domain),
            product: .framework
        )
    ]
)

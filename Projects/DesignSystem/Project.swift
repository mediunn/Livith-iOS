//
//  Project.swift
//  DesignSystem
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .designSystem,
    targets: [
        .make(
            target: .designSystem(.designSystem),
            product: .framework,
            dependencies: [
                .external(.kingfisher)
            ]
        )
    ]
)

//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .login,
    targets: [
        .make(
            target: .login(.loginFeature),
            product: .framework,
            dependencies: [
                .dsKit()
            ]
        )
    ]
)

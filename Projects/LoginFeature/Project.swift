//
//  Project.swift
//  Login
//
//  Created by 김진웅 on 10/12/25.
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
                .domain(.domain),
                .sharedFeature(.nicknameEditFeature),
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer)
            ]
        )
    ]
)

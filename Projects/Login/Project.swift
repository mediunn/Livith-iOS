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
            target: .login(.loginData),
            product: .framework,
            dependencies: [
                .login(.loginDomain),
                .core(.diContainer),
                .core(.livithNetwork)
            ]
        ),
        .make(
            target: .login(.loginDomain),
            product: .framework
        ),
        .make(
            target: .login(.loginFeature),
            product: .framework,
            dependencies: [
                .login(.loginDomain),
                .dsKit(),
                .core(.routing),
                .core(.diContainer)
            ]
        )
    ]
)

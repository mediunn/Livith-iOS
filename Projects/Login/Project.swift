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
                .core(.livithNetwork),
                .core(.socialAuth),
                .core(.persistence)
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
                .designSystem(.designSystem),
                .core(.coordinator),
                .core(.diContainer)
            ]
        )
    ]
)

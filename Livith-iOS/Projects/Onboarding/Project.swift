//
//  Project.swift
//  Onboarding
//
//  Created by 김진웅 on 10/12/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .onboarding,
    targets: [
        .make(
            target: .onboarding(.onboardingFeature),
            product: .framework,
            dependencies: [
                .shared(.designSystem),
                .core(.routing)
            ]
        )
    ]
)

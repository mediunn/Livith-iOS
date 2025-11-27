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
            target: .onboarding(.onboardingData),
            product: .framework,
            dependencies: [
                .onboarding(.onboardingDomain),
                .core(.livithNetwork)
            ]
        ),
        .make(
            target: .onboarding(.onboardingDomain),
            product: .framework
        ),
        .make(
            target: .onboarding(.onboardingFeature),
            product: .framework,
            dependencies: [
                .onboarding(.onboardingDomain),
                .dsKit(),
                .core(.routing),
                .core(.diContainer)
            ]
        )
    ]
)

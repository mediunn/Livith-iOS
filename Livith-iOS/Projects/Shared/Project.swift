//
//  Project.swift
//  AppManifests
//
//  Created by 김진웅 on 10/17/25.
//

import ProjectDescription

let project = Project(
    name: "Shared",
    organizationName: "Livith",
    targets: [
        .target(
            name: "DesignSystem",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["DesignSystem/Sources/**"],
            resources: ["DesignSystem/Resources/**"],
            dependencies: [
                .external(name: "Kingfisher")
            ]
        )
    ]
)

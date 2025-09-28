//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "LoginFeature",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "LoginFeature",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.loginfeature",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "DesignSystem", path: "../DesignSystem")
            ]
        )
    ]
)

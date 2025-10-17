//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "Login",
    organizationName: "Livith",
    targets: [
        .target(
            name: "LoginFeature",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.loginfeature",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["LoginFeature/Sources/**"],
            resources: nil,
            dependencies: [
                .project(target: "DesignSystem", path: .relativeToRoot("Projects/Shared"))
            ]
        )
    ]
)

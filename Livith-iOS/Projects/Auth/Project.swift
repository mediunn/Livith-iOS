//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "Auth",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "Auth",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.auth",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        )
    ]
)

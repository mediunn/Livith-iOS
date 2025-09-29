//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "Dependency",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "Dependency",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.dependency",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        )
    ]
)

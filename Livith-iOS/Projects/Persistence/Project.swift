//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "Persistence",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "Persistence",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.persistence",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        )
    ]
)

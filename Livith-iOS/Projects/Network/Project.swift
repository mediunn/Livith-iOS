//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription

let project = Project(
    name: "Network",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "Network",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.network",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Alamofire")
            ]
        )
    ]
)

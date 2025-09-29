//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription

let project = Project(
    name: "DesignSystem",
    organizationName: "Youjin Lee",
    packages: [],
    targets: [
        Target.target(
            name: "DesignSystem",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Kingfisher")
            ]
        )
    ]
)

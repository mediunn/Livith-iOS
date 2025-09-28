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
    packages: [
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "8.2.0"))
    ],
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
                .package(product: "Kingfisher")
            ]
        )
    ]
)

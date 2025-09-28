//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "Youjin Lee",
    settings: .settings(base: ["DEVELOPMENT_TEAM": "2DF5SKQK2R"]),
    targets: [
        Target.target(
            name: "Livith-iOS",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.youz2me.livith",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
//                .project(target: "Auth", path: "../Auth"),
//                .project(target: "DesignSystem", path: "../DesignSystem"),
//                .project(target: "Dependency", path: "../Dependency"),
//                .project(target: "Network", path: "../Network"),
//                .project(target: "Persistence", path: "../Persistence"),
                .project(target: "LoginFeature", path: "../LoginFeature"),
            ]
        )
    ]
)

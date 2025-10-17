//
//  Project.swift
//  Core
//
//  Created by 김진웅 on 10/12/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Core",
    organizationName: "Livith",
    targets: [
        .target(
            name: "DIContainer",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.dicontainer",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["DIContainer/Sources/**"],
            resources: nil,
            dependencies: []
        ),
        .target(
            name: "PerformanceMonitor",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.performancemonitor",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["PerformanceMonitor/Sources/**"],
            resources: nil,
            dependencies: []
        ),
        .target(
            name: "Routing",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.routing",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Routing/Sources/**"],
            resources: nil,
            dependencies: []
        ),
        .target(
            name: "Persistence",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.persistence",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Persistence/Sources/**"],
            resources: nil,
            dependencies: []
        ),
        .target(
            name: "Network",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.youz2me.livith.network",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .file(path: "Network/Resources/Info.plist"),
            sources: ["Network/Sources/**"],
            resources: nil,
            dependencies: [
                .external(name: "Alamofire")
            ],
            settings: .environment
        )
    ]
)

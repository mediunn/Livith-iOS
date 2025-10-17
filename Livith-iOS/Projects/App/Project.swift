//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    organizationName: "Livith",
    settings: .environment,
    targets: [
        .target(
            name: BuildConfiguration.appName,
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.youz2me.livith",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "LoginFeature", path: .relativeToRoot("Projects/Login"))
            ]
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

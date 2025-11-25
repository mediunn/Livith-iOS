//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .app,
    settings: .environment,
    targets: [
        .make(
            target: .app,
            product: .app,
            infoPlist: .file(path: "Resources/App-Info.plist"),
            dependencies: [
                .shared(.designSystem),
                .login(.loginFeature),
                .search(.searchFeature),
                .search(.searchData),
                .core(.diContainer)
            ]
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

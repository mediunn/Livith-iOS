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
            entitlements: .file(path: "Resources/Livith-iOS.entitlements"),
            dependencies: [
                .concert(.concertData),
                .concert(.concertFeature),
                .home(.homeData),
                .home(.homeFeature),
                .login(.loginData),
                .login(.loginFeature),
                .search(.searchData),
                .search(.searchFeature),
                .data(.setlistData),
                .setlist(.setlistFeature),
                .data(.songData),
                .song(.songFeature),
                .user(.userData),
                .user(.userFeature),
                .widget(.widget),
            ]
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

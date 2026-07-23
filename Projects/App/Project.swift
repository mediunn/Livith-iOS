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
                .concert(.concertFeature),
                .data(.commentData),
                .data(.concertData),
                .data(.notificationData),
                .home(.homeFeature),
                .login(.loginFeature),
                .data(.searchData),
                .search(.searchFeature),
                .data(.setlistData),
                .setlist(.setlistFeature),
                .data(.songData),
                .song(.songFeature),
                .data(.authData),
                .data(.userData),
                .user(.userFeature),
                .data(.preferenceData),
                .data(.calendarData),
                .livithNetworking(.livithNetworking),
                .core(.amplitude)
            ],
            settings: .settings(
                base: ["OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]]
            )
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

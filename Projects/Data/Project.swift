//
//  Project.swift
//  Manifests
//
//  Created by 김진웅 on 1/21/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .data,
    targets: [
        .make(
            target: .data(.authData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.socialAuth),
                .livithNetworking(.livithNetworking),
                .core(.livithFoundation),
                .core(.persistence),
                .core(.diContainer),
                .external(.firebaseMessaging)
            ],
            settings: .settings(
                base: ["OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]]
            )
        ),
        .make(
            target: .data(.authDataTests),
            product: .unitTests,
            dependencies: [
                .data(.authData)
            ]
        ),
        .make(
            target: .data(.commentData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.commentDataTests),
            product: .unitTests,
            dependencies: [
                .data(.commentData)
            ]
        ),
        .make(
            target: .data(.concertData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.concertDataTests),
            product: .unitTests,
            dependencies: [
                .data(.concertData)
            ]
        ),
        .make(
            target: .data(.preferenceData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.preferenceDataTests),
            product: .unitTests,
            dependencies: [
                .data(.preferenceData)
            ]
        ),
        .make(
            target: .data(.searchData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.searchDataTests),
            product: .unitTests,
            dependencies: [
                .data(.searchData)
            ]
        ),
        .make(
            target: .data(.setlistData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.setlistDataTests),
            product: .unitTests,
            dependencies: [
                .data(.setlistData)
            ]
        ),
        .make(
            target: .data(.songData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.songDataTests),
            product: .unitTests,
            dependencies: [
                .data(.songData)
            ]
        ),
        .make(
            target: .data(.userData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking),
                .core(.persistence)
            ]
        ),
        .make(
            target: .data(.userDataTests),
            product: .unitTests,
            dependencies: [
                .data(.userData)
            ]
        ),
        .make(
            target: .data(.notificationData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking),
                .core(.persistence)
            ]
        ),
        .make(
            target: .data(.notificationDataTests),
            product: .unitTests,
            dependencies: [
                .data(.notificationData)
            ]
        ),
        .make(
            target: .data(.calendarData),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .livithNetworking(.livithNetworking)
            ]
        ),
        .make(
            target: .data(.calendarDataTests),
            product: .unitTests,
            dependencies: [
                .data(.calendarData)
            ]
        )
    ]
)

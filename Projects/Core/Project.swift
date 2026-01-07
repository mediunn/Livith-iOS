//
//  Project.swift
//  Core
//
//  Created by 김진웅 on 10/12/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .core,
    targets: [
        .make(
            target: .core(.diContainer),
            product: .framework
        ),
        .make(
            target: .core(.livithNetwork),
            product: .framework,
            infoPlist: .file(path: "LivithNetwork/Resources/Network-Info.plist"),
            dependencies: [
                .external(.alamofire)
            ],
            settings: .environment
        ),
        .make(
            target: .core(.persistence),
            product: .framework
        ),
        .make(
            target: .core(.livithFoundation),
            product: .framework
        ),
        .make(
            target: .core(.socialAuth),
            product: .framework,
            dependencies: [
                .external(.kakaoSDKAuth),
                .external(.kakaoSDKUser),
                .external(.kakaoSDKCommon)
            ]
        )
    ]
)

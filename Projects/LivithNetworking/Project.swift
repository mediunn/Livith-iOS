//
//  Project.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .livithNetworking,
    targets: [
        .make(
            target: .livithNetworking(.livithNetworking),
            product: .framework
        ),
        .make(
            target: .livithNetworking(.livithNetworkingTests),
            product: .unitTests,
            dependencies: [
                .livithNetworking(.livithNetworking)
            ]
        )
    ]
)

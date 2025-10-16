//
//  Project.swift
//  Manifests
//
//  Created by Youjin Lee on 10/16/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.searchfeature

let project = Project.make(
    module: module,
    targets: [
        Target.make(
            module: module,
            product: .framework,
            resources: .default,
            dependencies: [
                .designSystem,
                .network
            ]
        )
    ]
)

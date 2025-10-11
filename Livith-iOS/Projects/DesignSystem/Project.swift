//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.designsystem

let project = Project.make(
    module: module,
    targets: [
        Target.make(
            module: module,
            product: .framework,
            resources: .default,
            dependencies: [
                .external(.kingfisher)
            ]
        )
    ]
)

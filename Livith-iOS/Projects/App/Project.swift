//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.app

let project = Project.make(
    module: module,
    settings: .environment,
    targets: [
        Target.make(
            module: module,
            product: .app,
            name: BuildConfiguration.appName,
            dependencies: [
//                .auth,
                .designSystem,
//                .dependency,
//                .network,
                .loginFeature,
            ]
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

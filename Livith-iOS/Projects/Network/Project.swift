//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.network

let project = Project.make(
    module: module,
    settings: .environment,
    targets: [
        Target.make(
            module: module,
            product: .framework,
            infoPlist: .file(path: .relativeToRoot("Projects/Network/Resources/Info.plist")),
            dependencies: [
                .external(.alamofire)
            ]
        )
    ]
)

//
//  Project.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.dependency

let project = Project.make(
    module: module,
    targets: [
        Target.make(
            module: module,
            product: .framework
        )
    ]
)

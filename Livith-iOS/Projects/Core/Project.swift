//
//  Project.swift
//  Core
//
//  Created by 김진웅 on 10/12/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let module = Module.core

let project = Project.make(
    module: module,
    targets: [
        Target.make(
            module: module,
            product: .framework
        )
    ]
)

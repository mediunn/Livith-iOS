//
//  Workspace.swift
//  
//
//  Created by YOUJIM on 9/28/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: BuildConfiguration.appName,
    projects: [
        "Projects/**"
    ]
)

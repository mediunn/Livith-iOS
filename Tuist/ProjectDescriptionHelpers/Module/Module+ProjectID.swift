//
//  ProjectID.swift
//  Manifests
//
//  Created by Youjin Lee on 11/2/25.
//

import ProjectDescription

// MARK: - ProjectID

public enum ProjectID: String, CaseIterable {
    case app = "App"
    case core = "Core"
    case shared = "Shared"
    case search = "Search"
    case login = "Login"
    case onboarding = "Onboarding"
    
    public var name: String { rawValue }
    
    public var path: Path {
        .relativeToRoot("Projects/\(rawValue)")
    }
}

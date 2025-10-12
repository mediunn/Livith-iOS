//
//  Module.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

public enum Module: String {
    case app
    case auth
    case core
    case dependency
    case designsystem
    case loginfeature
    case network
    case persistence

    public var name: String {
        return rawValue
    }

    public var dependency: TargetDependency {
        return .project(target: self.name, path: .relativeToRoot("Projects/\(self.projectFolderName)"))
    }

    private var projectFolderName: String {
        switch self {
        case .app: return "App"
        case .auth: return "Auth"
        case .core: return "Core"
        case .dependency: return "Dependency"
        case .designsystem: return "DesignSystem"
        case .loginfeature: return "LoginFeature"
        case .network: return "Network"
        case .persistence: return "Persistence"
        }
    }
}

//
//  Module.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

// MARK: - ProjectName
public enum ProjectName: String, CaseIterable {
    case app = "App"
    case core = "Core"
    case shared = "Shared"
    case login = "Login"
    
    public var name: String { rawValue }
    
    public var path: Path {
        .relativeToRoot("Projects/\(rawValue)")
    }
}

// MARK: - TargetName
public enum TargetName {
    case app
    case core(CoreModule)
    case login(LoginModule)
    case shared(SharedModule)
    
    public var name: String {
        switch self {
        case .app: return BuildConfiguration.appName
        case .core(let module): return module.rawValue
        case .shared(let module): return module.rawValue
        case .login(let module): return module.rawValue
        }
    }
    
    public var bundleId: String {
        switch self {
        case .app:
            return BuildConfiguration.baseBundleID
        default:
            return "\(BuildConfiguration.baseBundleID).\(name.lowercased())"
        }
    }
    
    public var sourcesPath: SourceFilesList {
        switch self {
        case .app:
            return ["Sources/**"]
        case .core(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .shared(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .login(let module):
            return ["\(module.rawValue)/Sources/**"]
        }
    }
    
    public var resourcesPath: ResourceFileElements? {
        switch self {
        case .shared(let module):
            switch module {
            case .designSystem:
                return ["DesignSystem/Resources/**"]
            }
        case .app:
            return ["Resources/**"]
        default:
            return nil
        }
    }
}

// MARK: - Core Module
public enum CoreModule: String {
    case diContainer = "DIContainer"
    case performanceMonitor = "PerformanceMonitor"
    case routing = "Routing"
    case persistence = "Persistence"
    case network = "Network"
}

// MARK: - Shared Module
public enum SharedModule: String {
    case designSystem = "DesignSystem"
}

// MARK: - Login Module
public enum LoginModule: String {
    case loginFeature = "LoginFeature"
}

// MARK: - External Dependency
public enum ExternalDependency: String {
    case alamofire = "Alamofire"
    case kingfisher = "Kingfisher"
}

//
//  TargetID.swift
//  Manifests
//
//  Created by Youjin Lee on 11/2/25.
//

import ProjectDescription

// MARK: - TargetID

public enum TargetID {
    case app
    case core(CoreModule)
    case login(LoginModule)
    case shared(SharedModule)
    case search(SearchModule)
    
    public var name: String {
        switch self {
        case .app: return BuildConfiguration.appName
        case .core(let module): return module.rawValue
        case .shared(let module): return module.rawValue
        case .login(let module): return module.rawValue
        case .search(let module): return module.rawValue
        }
    }
    
    public var bundleID: String {
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
        case .search(let module):
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

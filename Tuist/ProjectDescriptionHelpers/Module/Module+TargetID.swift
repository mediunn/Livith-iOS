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
    case dsKit
    case search(SearchModule)
    case setlist(SetlistModule)
    case concert(ConcertModule)
    case home(HomeModule)
    case user(UserModule)

    public var name: String {
        switch self {
        case .app: return BuildConfiguration.appName
        case .core(let module): return module.rawValue
        case .dsKit: return "DSKit"
        case .login(let module): return module.rawValue
        case .search(let module): return module.rawValue
        case .setlist(let module): return module.rawValue
        case .concert(let module): return module.rawValue
        case .home(let module): return module.rawValue
        case .user(let module): return module.rawValue
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
        case .dsKit:
            return ["Sources/**"]
        case .login(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .search(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .setlist(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .concert(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .home(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .user(let module):
            return ["\(module.rawValue)/Sources/**"]
        }
    }
    
    public var resourcesPath: ResourceFileElements? {
        switch self {
        case .dsKit:
            return ["Resources/**"]
        case .app:
            return [
                .glob(pattern: "Resources/**", excluding: [
                    "Resources/App-Info.plist",
                    "Resources/Livith-iOS.entitlements"
                ])
            ]
        default:
            return nil
        }
    }
}

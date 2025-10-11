//
//  TargetDependency+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

// MARK: - Module Constant

extension TargetDependency {
    public static let app: Self = Module.app.dependency
    public static let auth: Self = Module.auth.dependency
    public static let dependency: Self = Module.dependency.dependency
    public static let designSystem: Self = Module.designsystem.dependency
    public static let loginFeature: Self = Module.loginfeature.dependency
    public static let network: Self = Module.network.dependency
    public static let persistence: Self = Module.persistence.dependency
}

// MARK: - External Dependencies Constant

public enum ExternalDependency {
    case alamofire
    case kingfisher
}

extension TargetDependency {
    public static func external(_ dependency: ExternalDependency) -> TargetDependency {
        switch dependency {
        case .alamofire: return .external(name: "Alamofire")
        case .kingfisher: return .external(name: "Kingfisher")
        }
    }
}

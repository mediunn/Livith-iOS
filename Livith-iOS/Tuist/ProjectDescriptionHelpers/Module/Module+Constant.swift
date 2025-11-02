//
//  Modules.swift
//  Manifests
//
//  Created by 김진웅 on 11/2/25.
//

import ProjectDescription

// MARK: - Core Module

public enum CoreModule: String {
    case diContainer = "DIContainer"
    case performanceMonitor = "PerformanceMonitor"
    case routing = "Routing"
    case persistence = "Persistence"
    case livithNetwork = "LivithNetwork"
}

// MARK: - Shared Module

public enum SharedModule: String {
    case designSystem = "DesignSystem"
}

// MARK: - Login Module

public enum LoginModule: String {
    case loginFeature = "LoginFeature"
}

// MARK: - Search Module

public enum SearchModule: String {
    case searchData = "SearchData"
    case searchDomain = "SearchDomain"
    case searchFeature = "SearchFeature"
}


// MARK: - External Dependency

public enum ExternalDependency: String {
    case alamofire = "Alamofire"
    case kingfisher = "Kingfisher"
}

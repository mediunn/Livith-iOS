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
    case livithConcurrency = "LivithConcurrency"
}

// MARK: - DSKitModule Module

public enum DSKitModule: String {
    case dsKit = "DSKit"
}

// MARK: - Login Module

public enum LoginModule: String {
    case loginFeature = "LoginFeature"
}

// MARK: - Onboarding Module

public enum OnboardingModule: String {
    case onboardingData = "OnboardingData"
    case onboardingDomain = "OnboardingDomain"
    case onboardingFeature = "OnboardingFeature"
}

// MARK: - Search Module

public enum SearchModule: String {
    case searchData = "SearchData"
    case searchDomain = "SearchDomain"
    case searchFeature = "SearchFeature"
}


// MARK: - User Module

public enum UserModule: String {
    case userData = "UserData"
    case userDomain = "UserDomain"
    case userFeature = "UserFeature"
}

// MARK: - External Dependency

public enum ExternalDependency: String {
    case alamofire = "Alamofire"
    case kingfisher = "Kingfisher"
}

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
    case persistence = "Persistence"
    case livithNetwork = "LivithNetwork"
    case livithFoundation = "LivithFoundation"
    case socialAuth = "SocialAuth"
    case coordinator = "Coordinator"
}

// MARK: - Login Module

public enum LoginModule: String {
    case loginFeature = "LoginFeature"
}

// MARK: - Search Module

public enum SearchModule: String {
    case searchFeature = "SearchFeature"
}


// MARK: - User Module

public enum UserModule: String {
    case userFeature = "UserFeature"
}


// MARK: - Home Module

public enum HomeModule: String {
    case homeFeature = "HomeFeature"
}


// MARK: - Concert Module

public enum ConcertModule: String {
    case concertFeature = "ConcertFeature"
}


// MARK: - Setlist Module

public enum SetlistModule: String {
    case setlistFeature = "SetlistFeature"
}


// MARK: - Song Module

public enum SongModule: String {
    case songFeature = "SongFeature"
}

// MARK: - Widget Module

public enum WidgetModule: String {
    case widget = "LivithWidget"
}

// MARK: - Domain Module

public enum DomainModule: String {
    case domain = "Domain"
}

// MARK: - Data Module

public enum DataModule: String {
    case data = "Data"
    case authData = "AuthData"
    case authDataTests = "AuthDataTests"
    case commentData = "CommentData"
    case commentDataTests = "CommentDataTests"
    case concertData = "ConcertData"
    case concertDataTests = "ConcertDataTests"
    case searchData = "SearchData"
    case searchDataTests = "SearchDataTests"
    case setlistData = "SetlistData"
    case setlistDataTests = "SetlistDataTests"
    case songData = "SongData"
    case songDataTests = "SongDataTests"
    case userData = "UserData"
    case userDataTests = "UserDataTests"
    case dataTests = "DataTests"
}

// MARK: - DesignSystem Module

public enum DesignSystemModule: String {
    case designSystem = "LivithDesignSystem"
}

// MARK: - External Dependency

public enum ExternalDependency: String {
    case alamofire = "Alamofire"
    case kingfisher = "Kingfisher"
    case kakaoSDKCommon = "KakaoSDKCommon"
    case kakaoSDKAuth = "KakaoSDKAuth"
    case kakaoSDKUser = "KakaoSDKUser"
    case youTubePlayerKit = "YouTubePlayerKit"
}

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
    case loginData = "LoginData"
    case loginDomain = "LoginDomain"
    case loginFeature = "LoginFeature"
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


// MARK: - Home Module

public enum HomeModule: String {
    case homeData = "HomeData"
    case homeDomain = "HomeDomain"
    case homeFeature = "HomeFeature"
}


// MARK: - Concert Module

public enum ConcertModule: String {
    case concertData = "ConcertData"
    case concertDomain = "ConcertDomain"
    case concertFeature = "ConcertFeature"
    case concertTests = "ConcertTests"
}


// MARK: - Setlist Module

public enum SetlistModule: String {
    case setlistFeature = "SetlistFeature"
}


// MARK: - Song Module

public enum SongModule: String {
    case songData = "SongData"
    case songDomain = "SongDomain"
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
    case authData = "TempAuthData"
    case authDataTests = "TempAuthDataTests"
    case commentData = "TempCommentData"
    case commentDataTests = "TempCommentDataTests"
    case concertData = "TempConcertData"
    case concertDataTests = "TempConcertDataTests"
    case searchData = "TempSearchData"
    case searchDataTests = "TempSearchDataTests"
    case setlistData = "TempSetlistData"
    case setlistDataTests = "TempSetlistDataTests"
    case songData = "TempSongData"
    case songDataTests = "TempSongDataTests"
    case userData = "TempUserData"
    case userDataTests = "TempUserDataTests"
    case dataTests = "DataTests"
}

// MARK: - External Dependency

public enum ExternalDependency: String {
    case alamofire = "Alamofire"
    case kingfisher = "Kingfisher"
    case kakaoSDKCommon = "KakaoSDKCommon"
    case kakaoSDKAuth = "KakaoSDKAuth"
    case kakaoSDKUser = "KakaoSDKUser"
    case youTubePlayerKit = "YouTubePlayerKit"
    case livithDesignSystem = "LivithDesignSystem"
}

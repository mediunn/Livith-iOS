//
//  DataAssembler.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetwork
import Persistence
import SocialAuth

public struct DataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerNetwork(to: container)
        registerSocialAuth(to: container)
        registerRepositories(to: container)
    }
}

// MARK: - Repositories Registration

private extension DataAssembler {
    func registerRepositories(to container: any DependencyContainer) {
        registerConcertRepository(to: container)
        registerSearchRepository(to: container)
        registerUserRepository(to: container)
        registerSetlistRepository(to: container)
        registerCommentRepository(to: container)
        registerSongRepository(to: container)
        registerAuthRepository(to: container)
    }
    
    func registerConcertRepository(to container: any DependencyContainer) {
        let concertRepo = ConcertRepositoryImpl(
            homeService: container.resolve(HomeService.self),
            searchService: container.resolve(SearchService.self),
            concertService: container.resolve(ConcertService.self),
            setlistService: container.resolve(SetlistService.self)
        )
        container.register(concertRepo, for: ConcertRepository.self)
    }
    
    func registerSearchRepository(to container: any DependencyContainer) {
        let searchRepo = SearchRepositoryImpl(
            searchService: container.resolve(SearchService.self)
        )
        container.register(searchRepo, for: SearchRepository.self)
    }
    
    func registerUserRepository(to container: any DependencyContainer) {
        let userRepo = UserRepositoryImpl(
            onboardingService: container.resolve(OnboardingService.self),
            homeService: container.resolve(HomeService.self),
            userService: container.resolve(UserService.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self),
            widgetImageStorage: container.resolve(WidgetImageStorage.self)
        )
        container.register(userRepo, for: UserRepository.self)
    }
    
    func registerSetlistRepository(to container: any DependencyContainer) {
        let setlistRepo = SetlistRepositoryImpl(
            setlistService: container.resolve(SetlistService.self)
        )
        container.register(setlistRepo, for: SetlistRepository.self)
    }
    
    func registerCommentRepository(to container: any DependencyContainer) {
        let commentRepo = CommentRepositoryImpl(
            commentService: container.resolve(CommentService.self)
        )
        container.register(commentRepo, for: CommentRepository.self)
    }
    
    func registerSongRepository(to container: any DependencyContainer) {
        let songRepo = SongRepositoryImpl(
            songService: container.resolve(SongService.self)
        )
        container.register(songRepo, for: SongRepository.self)
    }
    
    func registerAuthRepository(to container: any DependencyContainer) {
        let authRepo = AuthRepositoryImpl(
            socialAuthService: container.resolve(SocialAuthService.self),
            onboardingService: container.resolve(OnboardingService.self),
            userService: container.resolve(UserService.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self),
            tokenService: container.resolve(TokenService.self)
        )
        container.register(authRepo, for: AuthRepository.self)
    }
}

// MARK: - Persistence Registration

private extension DataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
        container.register(WidgetImageStorage(), for: WidgetImageStorage.self)
    }
}

// MARK: - SocialAuth Registration

private extension DataAssembler {
    func registerSocialAuth(to container: any DependencyContainer) {
        container.register(SocialAuthService(), for: SocialAuthService.self)
    }
}

// MARK: - Network Registration

private extension DataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(HomeService(), for: HomeService.self)
        container.register(SearchService(), for: SearchService.self)
        container.register(ConcertService(), for: ConcertService.self)
        container.register(SetlistService(), for: SetlistService.self)
        container.register(CommentService(), for: CommentService.self)
        container.register(SongService(), for: SongService.self)
        container.register(UserService(), for: UserService.self)
        container.register(OnboardingService(), for: OnboardingService.self)
    }
}

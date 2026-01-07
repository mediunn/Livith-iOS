//
//  UserRepositoryImpl.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import Persistence
import UserDomain

public final class UserRepositoryImpl {
    private let userService: NetworkService<UserEndpoint>
    private let logoutService: NetworkService<LogoutEndpoint>
    private let tokenService: TokenService
    private let localStorage: UserDefaultsStorage
    private let userErrorMapper: UserErrorMapper = .init()

    public init(
        userService: NetworkService<UserEndpoint> = .init(),
        logoutService: NetworkService<LogoutEndpoint> = .init(interceptor: nil),
        tokenService: TokenService = TokenServiceImpl(),
        localStorage: UserDefaultsStorage = UserDefaultsStorage()
    ) {
        self.userService = userService
        self.logoutService = logoutService
        self.tokenService = tokenService
        self.localStorage = localStorage
    }
}

extension UserRepositoryImpl: UserRepository {
    public func checkNicknameDuplicate(nickname: String) async throws(UserError) -> Bool {
        do {
            let response: DTO.Response.CheckNicknameDuplicate = try await userService.request(
                UserEndpoint.checkNicknameDuplicate(nickname: nickname)
            )
            
            return response.available
        } catch let error{
            throw userErrorMapper.mapToUserError(error)
        }
    }
    
    public func updateUserNickname(nickname: String) async throws(UserError) -> String {
        do {
            let request = DTO.Request.UpdateUserNickname(nickname: nickname)

            let response: DTO.Response.UpdateUserNickname = try await userService.request(
                UserEndpoint.updateUserNickname(request: request)
            )

            updateStoredUserNickname(response.nickname)

            return response.nickname
        } catch let error {
            throw userErrorMapper.mapToUserError(error)
        }
    }

    private func updateStoredUserNickname(_ nickname: String) {
        guard let currentUser: DTO.Response.FetchUserInfo = try? localStorage.fetch(for: .currentUser) else {
            return
        }

        let updatedUser = DTO.Response.FetchUserInfo(
            id: currentUser.id,
            interestConcertID: currentUser.interestConcertID,
            provider: currentUser.provider,
            providerID: currentUser.providerID,
            email: currentUser.email,
            nickname: nickname,
            marketingConsent: currentUser.marketingConsent
        )

        try? localStorage.save(updatedUser, for: .currentUser)
    }
    
    public func deleteUser(reason: String) async throws(UserError) {
        do {
            let request = DTO.Request.DeleteUser(reason: reason)

            let _: DTO.Response.DeleteUser = try await userService.request(
                UserEndpoint.deleteUser(request: request)
            )
        } catch {
            throw userErrorMapper.mapToUserError(error)
        }

        // 백엔드 삭제 성공 후에는 로컬 정리가 반드시 실행되어야 함
        try? await tokenService.removeToken()
        localStorage.remove(for: .currentUser)
        localStorage.remove(for: LocalStorageKeys.lastLoginPlatform)
    }
    
    public func logoutSession() async throws(UserError) {
        do {
            let refreshToken = try await tokenService.getRefreshToken()
            let request = DTO.Request.RequestLogout(refreshToken: refreshToken)

            let _: DTO.Response.RequestLogout = try await logoutService.request(
                LogoutEndpoint.logoutSession(request: request)
            )
        } catch {
            throw userErrorMapper.mapToUserError(error)
        }

        // 백엔드 로그아웃 성공 후에는 로컬 정리가 반드시 실행되어야 함
        try? await tokenService.removeToken()
        localStorage.remove(for: .currentUser)
    }
}

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
    private let localStorage: LocalKeyValueStorage
    private let userErrorMapper: UserErrorMapper = .init()

    public init(
        userService: NetworkService<UserEndpoint> = .init(),
        logoutService: NetworkService<LogoutEndpoint> = .init(interceptor: nil),
        tokenService: TokenService = TokenServiceImpl(),
        localStorage: LocalKeyValueStorage = UserDefaultsStorage()
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
            
            return response.nickname
        } catch let error {
            throw userErrorMapper.mapToUserError(error)
        }
    }
    
    public func deleteUser(reason: String) async throws(UserError) {
        do {
            let request = DTO.Request.DeleteUser(reason: reason)
            
            let _: DTO.Response.DeleteUser = try await userService.request(
                UserEndpoint.deleteUser(request: request)
            )

            try await tokenService.removeToken()
            localStorage.remove(for: LocalStorageKeys.currentUser)
            localStorage.remove(for: LocalStorageKeys.lastLoginPlatform)
        } catch {
            throw userErrorMapper.mapToUserError(error)
        }
    }
    
    public func logoutSession() async throws(UserError) {
        do {
            let refreshToken = try await tokenService.getRefreshToken()
            let request = DTO.Request.RequestLogout(refreshToken: refreshToken)

            let _: DTO.Response.RequestLogout = try await logoutService.request(
                LogoutEndpoint.logoutSession(request: request)
            )

            try await tokenService.removeToken()
            localStorage.remove(for: LocalStorageKeys.currentUser)
        } catch {
            throw userErrorMapper.mapToUserError(error)
        }
    }
}

// MARK: - LocalStorageKeys

private enum LocalStorageKeys {
    static let currentUser = "currentUser"
    static let lastLoginPlatform = "lastLoginPlatform"
}

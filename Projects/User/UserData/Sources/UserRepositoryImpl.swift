//
//  UserRepositoryImpl.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import UserDomain

public final class UserRepositoryImpl {
    // TODO: 토큰 서비스 선언
    private let userService: NetworkService<UserEndpoint>
    private let logoutService: NetworkService<LogoutEndpoint>
    private let userErrorMapper: UserErrorMapper = .init()

    public init(
        userService: NetworkService<UserEndpoint> = .init(),
        logoutService: NetworkService<LogoutEndpoint> = .init(interceptor: nil)
    ) {
        self.userService = userService
        self.logoutService = logoutService
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
        } catch let error {
            throw userErrorMapper.mapToUserError(error)
        }
    }
    
    public func logoutSession() async throws(UserError) {
        // TODO: 토큰 서비스로 토큰 받아서 로그아웃 처리하기
    }
}

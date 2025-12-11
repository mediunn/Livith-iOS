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
    private let userService: NetworkService<UserEndpoint> = .init()
    private let logoutService: NetworkService<LogoutEndpoint> = .init(interceptor: nil)
    private let userErrorMapper: UserErrorMapper = .init()
}

extension UserRepositoryImpl: UserRepository {
    public func checkNicknameDuplicate(nickname: String) async throws(UserError) -> Bool {
        do {
            let response: BaseResponse<DTO.Response.CheckNicknameDuplicate> = try await userService.request(
                UserEndpoint.checkNicknameDuplicate(nickname: nickname)
            )
            
            guard let data = response.data else {
                throw UserError.unknown
            }
            
            return data.available
            
        } catch let error as UserError {
            throw error
        } catch let error as NetworkError {
            throw userErrorMapper.mapToUserError(error)
        } catch {
            throw UserError.unknown
        }
    }
    
    public func updateUserNickname(nickname: String) async throws(UserError) -> String {
        do {
            let response: BaseResponse<DTO.Response.UpdateUserNickname> = try await userService.request(
                UserEndpoint.checkNicknameDuplicate(nickname: nickname)
            )
            
            guard let data = response.data else {
                throw UserError.unknown
            }
            
            return data.nickname
        } catch let error as UserError {
            throw error
        } catch let error as NetworkError {
            throw userErrorMapper.mapToUserError(error)
        } catch {
            throw UserError.unknown
        }
    }
    
    public func deleteUser(reason: String) async throws(UserError) {
        do {
            let request = DTO.Request.DeleteUser(reason: reason)
            
            let response: BaseResponse<DTO.Response.DeleteUser> = try await userService.request(
                UserEndpoint.deleteUser(request: request)
            )
            
            guard let data = response.data else {
                throw UserError.unknown
            }
        } catch let error as UserError {
            throw error
        } catch let error as NetworkError {
            throw userErrorMapper.mapToUserError(error)
        } catch {
            throw UserError.unknown
        }
    }
    
    public func logoutSession() async throws(UserError) {
        // TODO: 토큰 서비스로 토큰 받아서 로그아웃 처리하기
    }
}

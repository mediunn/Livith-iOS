//
//  NetworkServiceProtocol.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol ConcertServiceProtocol {
    func request<T: Decodable>(_ endPoint: ConcertEndpoint) async throws(NetworkError) -> T
}

public protocol SetlistServiceProtocol {
    func request<T: Decodable>(_ endPoint: SetlistEndpoint) async throws(NetworkError) -> T
}

public protocol CommentServiceProtocol {
    func request<T: Decodable>(_ endPoint: CommentEndpoint) async throws(NetworkError) -> T
}

extension NetworkService: ConcertServiceProtocol where EndPoint == ConcertEndpoint {}
extension NetworkService: SetlistServiceProtocol where EndPoint == SetlistEndpoint {}
extension NetworkService: CommentServiceProtocol where EndPoint == CommentEndpoint {}

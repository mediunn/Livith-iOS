//
//  ServerResponse.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

struct ServerResponse<T: Decodable>: Decodable {
    public let statusCode: Int
    public let error: String?
    public let message: String
    public let data: T?
}

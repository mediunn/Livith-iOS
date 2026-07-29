//
//  NetworkConfig.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NetworkConfig: Sendable {
    private static var apiVersion: String {
        #if DEBUG
        return "v7"
        #else
        return "v7"
        #endif
    }
    
    public let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL.appendingPathComponent("api/\(Self.apiVersion)")
    }
}

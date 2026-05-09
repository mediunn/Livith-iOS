//
//  NetworkTransport.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

protocol NetworkTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

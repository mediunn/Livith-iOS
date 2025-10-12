//
//  RequestDescription.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public protocol NetworkEndpoint {
    var endPoint: String? { get }
    var method: HTTPMethod { get }
    var query: [String: Any]? { get }
    var body: Encodable? { get }
}

public extension NetworkEndpoint {
    var query: [String: Any]? { .none }
    var body: Encodable? { .none }
}

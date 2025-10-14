//
//  NetworkMonitor.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol NetworkMonitor {
    func willSend(_ request: URLRequest, endpoint: NetworkEndpoint)
    func didReceive(_ result: Result<Data, NetworkError>, endpoint: NetworkEndpoint, response: HTTPURLResponse?)
}

public extension NetworkMonitor {
    func willSend(_ request: URLRequest, endpoint: NetworkEndpoint) {}
    func didReceive(_ result: Result<Data, NetworkError>, endpoint: NetworkEndpoint, response: HTTPURLResponse?) {}
}

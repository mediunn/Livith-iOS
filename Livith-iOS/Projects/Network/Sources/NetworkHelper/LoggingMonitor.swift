//
//  LoggingMonitor.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public final class LoggingMonitor {
    public func willSend(_ request: URLRequest, endpoint: NetworkEndpoint) {
        print("🚀 [Request] =====================")
        print("URL: \(request.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
        print("Method: \(request.httpMethod ?? "HTTP 메서드를 찾을 수 없습니다")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        print("======================================\n")
    }

    public func didReceive(_ result: Result<Data, NetworkError>, endpoint: NetworkEndpoint, response: HTTPURLResponse?) {
        switch result {
        case .success(let data):
            print("✅ [Response] ====================")
            if let response = response {
                print("URL: \(response.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
                print("Status Code: \(response.statusCode)")
            }

            if let headers = response?.allHeaderFields {
                print("Headers: \(headers)")
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Response Body:\n\(prettyString)")
            }

            print("======================================\n")

        case .failure(let error):
            print("❌ [Error] =======================")
            if let response = response {
                print("Status Code: \(response.statusCode)")
                print("URL: \(response.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
            }
            print("Error: \(error.localizedDescription)")
            print("======================================\n")
        }
    }
}

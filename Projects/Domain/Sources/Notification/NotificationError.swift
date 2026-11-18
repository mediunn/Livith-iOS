//
//  NotificationError.swift
//  Domain
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum NotificationError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case notificationNotFound
    case cancelled
}

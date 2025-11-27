//
//  Task+.swift
//  search
//
//  Created by Youjin Lee on 10/16/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public extension Task where Success == Void, Failure == Never {
    /// Safe 버전: 에러를 던지지 않고 Bool로 상태 반환
    /// - Returns: 시간이 다 지났으면 true, 중간에 취소되었으면 false
    static func wait(for duration: Duration = .zero) async -> Bool {
        try? await Task<Never, Never>.sleep(for: duration)
        return !Task<Never, Never>.isCancelled
    }

    /// Throwing 버전: 취소되면 CancellationError를 던짐 (흐름 제어용)
    /// - Throws: CancellationError
    static func checkCancellation(after duration: Duration = .zero) async throws {
        try await Task<Never, Never>.sleep(for: duration)
        try Task<Never, Never>.checkCancellation()
    }
}

//
//  PerformanceMonitor.swift
//  core
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public final class PerformanceMonitor {
    private var manualMetrics: [String: (startTime: Date, startMemory: Double)] = [:]
    private let queue = DispatchQueue(label: "com.livith.performance.monitor", attributes: .concurrent)
    
    public init() {}
}

// MARK: - Sync/Async Extension

public extension PerformanceMonitor {
    @discardableResult
    func measure<T>(
        _ taskName: String,
        operation: () throws -> T
    ) rethrows -> T {
        let startMemory = getMemoryUsage()
        let startTime = Date()

        let result = try operation()

        let endTime = Date()
        let endMemory = getMemoryUsage()

        let duration = endTime.timeIntervalSince(startTime)
        let memoryUsed = endMemory - startMemory

        printMetric(taskName: taskName, duration: duration, memoryUsed: memoryUsed)

        return result
    }
    
    @discardableResult
    func measure<T>(
        _ taskName: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        let startMemory = getMemoryUsage()
        let startTime = Date()

        let result = try await operation()

        let endTime = Date()
        let endMemory = getMemoryUsage()

        let duration = endTime.timeIntervalSince(startTime)
        let memoryUsed = endMemory - startMemory

        printMetric(taskName: taskName, duration: duration, memoryUsed: memoryUsed)

        return result
    }
}

public extension PerformanceMonitor {
    func start(_ taskName: String) {
        let startMemory = getMemoryUsage()
        let startTime = Date()

        queue.async(flags: .barrier) { [weak self] in
            self?.manualMetrics[taskName] = (startTime, startMemory)
        }

        print("⏱️ [Performance] 측정 시작: \(taskName)")
    }

    func end(_ taskName: String) {
        let endTime = Date()
        let endMemory = getMemoryUsage()

        queue.sync { [weak self] in
            guard let metric = self?.manualMetrics[taskName] else {
                print("⚠️ [Performance] WARNING: 측정 시작 기록을 찾을 수 없습니다: \(taskName)")
                return
            }

            let duration = endTime.timeIntervalSince(metric.startTime)
            let memoryUsed = endMemory - metric.startMemory

            self?.queue.async(flags: .barrier) { [weak self] in
                self?.manualMetrics.removeValue(forKey: taskName)
            }

            self?.printMetric(taskName: taskName, duration: duration, memoryUsed: memoryUsed)
        }
    }
}


// MARK: - Private Helper

private extension PerformanceMonitor {
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        return Double(info.resident_size) / 1024.0 / 1024.0
    }

    private func printMetric(taskName: String, duration: TimeInterval, memoryUsed: Double) {
        print("⏱️ [Performance] ========================")
        print("작업: \(taskName)")
        print("소요 시간: \(String(format: "%.3f", duration))초")
        print("메모리 사용: \(String(format: "%.2f", memoryUsed)) MB")

        if duration > 1.0 {
            print("⚠️ [Performance] WARNING: 작업이 1초 이상 소요되었습니다")
        }

        if memoryUsed > 50.0 {
            print("⚠️ [Performance] WARNING: 메모리를 50MB 이상 사용했습니다")
        }

        print("==========================================\n")
    }
}

//
//  CalendarDayEvent+Display.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

// MARK: - Schedule Kind

extension CalendarDayEvent {
    enum ScheduleKind {
        case ticketing
        case performance
    }

    var scheduleKind: ScheduleKind {
        switch type {
        case .generalTicketing, .preTicketing, .addTicketing:
            return .ticketing
        case .concert:
            return .performance
        }
    }

    var isCancelled: Bool {
        status.isCancelled
    }

    var displayTitle: String {
        title ?? ""
    }

    var detailText: String {
        detail?.text ?? Constants.tbaLabel
    }

    var timeLabel: String {
        if isCancelled {
            return Constants.cancelledLabel
        }
        if let time {
            return String(format: "%02d:%02d", time.hour, time.minute)
        }
        return Constants.tbaLabel
    }

    var kindTitle: String {
        switch scheduleKind {
        case .ticketing:
            return "예매일"
        case .performance:
            return "공연일"
        }
    }
}

// MARK: - Constants

private extension CalendarDayEvent {
    enum Constants {
        static let cancelledLabel = "공연 취소"
        static let tbaLabel = "추후 발표"
    }
}

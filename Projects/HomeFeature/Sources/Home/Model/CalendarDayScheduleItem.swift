//
//  CalendarDayScheduleItem.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Item

struct CalendarDayScheduleItem: Equatable, Identifiable {
    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let time: Time?
    let isCancelled: Bool

    enum Kind: Equatable {
        case ticketing
        case performance
    }

    struct Time: Equatable, Comparable {
        let hour: Int
        let minute: Int

        static func < (lhs: Time, rhs: Time) -> Bool {
            if lhs.hour != rhs.hour {
                return lhs.hour < rhs.hour
            }
            return lhs.minute < rhs.minute
        }
    }
}

// MARK: - Display

extension CalendarDayScheduleItem {
    var timeLabel: String {
        if isCancelled {
            return Constants.cancelledLabel
        }
        if let time {
            return String(format: "%02d:%02d", time.hour, time.minute)
        }
        return Constants.tbaLabel
    }

    enum Constants {
        static let cancelledLabel = "공연 취소"
        static let tbaLabel = "추후 발표"
    }
}

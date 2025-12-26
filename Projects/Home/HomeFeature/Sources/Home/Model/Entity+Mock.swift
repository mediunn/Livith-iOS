//
//  Entity+Mock.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain

extension Concert {
	static func mock(
		id: Int,
		title: String,
		artist: String,
		status: ConcertStatus,
		daysLeft: Int,
		startDate: String,
		endDate: String,
		venue: String,
		ticketingOffice: String? = nil,
		label: String? = nil
	) -> Concert {
		Concert(
			id: id,
			title: title,
			artist: artist,
			status: status,
			daysLeft: daysLeft,
			startDate: startDate,
			endDate: endDate,
			posterURL: URL(string: "https://fastly.picsum.photos/id/927/100/158.jpg?hmac=ei6N2gefHzriiVfTXkd1KsZCICxvK-cBFd7zc6Oz0As")!,
			venue: venue,
			ticketSite: ticketingOffice,
			ticketURL: URL(string: "https://tickets.example.com/\(id)"),
			introduction: "\(artist)의 \(title) 공연",
			label: label
		)
	}
}

extension ConcertSection {
	static let mockSections: [ConcertSection] = [
		ConcertSection(
			id: 1,
			title: "이번 주 핫 공연",
			concerts: [
				.mock(id: 101, title: "Midnight Echo", artist: "LIV Band", status: .ongoing, daysLeft: 0, startDate: "2025-01-02", endDate: "2025-01-05", venue: "잠실 실내체육관", ticketingOffice: "Yes24", label: "단독"),
				.mock(id: 102, title: "Aurora Night", artist: "Stella", status: .ongoing, daysLeft: 0, startDate: "2025-01-04", endDate: "2025-01-06", venue: "올림픽홀", ticketingOffice: "Melon"),
				.mock(id: 103, title: "Neon Pulse", artist: "JUNE", status: .ongoing, daysLeft: 0, startDate: "2025-01-01", endDate: "2025-01-03", venue: "KSPO DOME", ticketingOffice: "Interpark", label: "앵콜"),
				.mock(id: 104, title: "Silver Lining", artist: "Harper", status: .upcoming, daysLeft: 5, startDate: "2025-01-06", endDate: "2025-01-08", venue: "블루스퀘어", ticketingOffice: "Yes24"),
				.mock(id: 105, title: "Echoes of Dawn", artist: "Mirae", status: .upcoming, daysLeft: 7, startDate: "2025-01-08", endDate: "2025-01-10", venue: "예술의전당", ticketingOffice: "Melon", label: "초연")
			]
		),
		ConcertSection(
			id: 2,
			title: "다가오는 공연",
			concerts: [
				.mock(id: 201, title: "Skyline", artist: "Noah", status: .upcoming, daysLeft: 9, startDate: "2025-01-10", endDate: "2025-01-12", venue: "인천문학경기장", ticketingOffice: "Yes24"),
				.mock(id: 202, title: "Moonlight", artist: "ARIA", status: .upcoming, daysLeft: 12, startDate: "2025-01-13", endDate: "2025-01-14", venue: "부산 BEXCO", ticketingOffice: "Interpark", label: "팬미팅"),
				.mock(id: 203, title: "Prism", artist: "VIOLET", status: .upcoming, daysLeft: 14, startDate: "2025-01-15", endDate: "2025-01-16", venue: "대구 엑스코", ticketingOffice: "Melon"),
				.mock(id: 204, title: "Sunrise", artist: "LEO", status: .upcoming, daysLeft: 16, startDate: "2025-01-17", endDate: "2025-01-18", venue: "창원체육관", ticketingOffice: "Yes24", label: "앵콜"),
				.mock(id: 205, title: "Gravity", artist: "Nova", status: .upcoming, daysLeft: 18, startDate: "2025-01-19", endDate: "2025-01-20", venue: "광주여대 유니버시아드", ticketingOffice: "Interpark")
			]
		),
		ConcertSection(
			id: 3,
			title: "지난 공연",
			concerts: [
				.mock(id: 301, title: "Afterglow", artist: "Rhea", status: .completed, daysLeft: 0, startDate: "2024-12-20", endDate: "2024-12-21", venue: "올림픽홀", ticketingOffice: "Melon"),
				.mock(id: 302, title: "Retro Wave", artist: "1984", status: .completed, daysLeft: 0, startDate: "2024-12-18", endDate: "2024-12-19", venue: "블루스퀘어", ticketingOffice: "Yes24"),
				.mock(id: 303, title: "Silent Bloom", artist: "Eden", status: .completed, daysLeft: 0, startDate: "2024-12-15", endDate: "2024-12-16", venue: "예술의전당", ticketingOffice: "Interpark", label: "단독"),
				.mock(id: 304, title: "City Lights", artist: "Mono", status: .completed, daysLeft: 0, startDate: "2024-12-12", endDate: "2024-12-13", venue: "KSPO DOME", ticketingOffice: "Melon"),
				.mock(id: 305, title: "Frost", artist: "North", status: .canceled, daysLeft: 0, startDate: "2024-12-10", endDate: "2024-12-10", venue: "부산 BEXCO", ticketingOffice: "Yes24", label: "공연취소")
			]
		)
	]
}


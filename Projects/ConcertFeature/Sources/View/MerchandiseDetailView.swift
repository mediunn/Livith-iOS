//
//  MerchandiseDetailView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct MerchandiseDetailView: View {

    // MARK: - Property

    @Environment(\.dismiss) private var dismiss

    let merchandiseList: [ConcertMerchandise]
    let ticketingOfficeURL: URL?
    let onTicketSiteReturn: () -> Void

    @State private var isTicketSheetPresented: Bool = false

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
        count: 3
    )

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            LivithNavigationView(
                type: .back(title: "MD 상세", onBack: { dismiss() })
            )

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(merchandiseList) { merchandise in
                        LivithCard(
                            imageURL: merchandise.imageURL,
                            title: merchandise.name,
                            subtitle: merchandise.price,
                            isFlexible: true
                        )
                        .onTapGesture {
                            if ticketingOfficeURL != nil {
                                isTicketSheetPresented = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .sheet(
            isPresented: $isTicketSheetPresented,
            onDismiss: { onTicketSiteReturn() }
        ) {
            if let ticketingOfficeURL {
                SafariView(url: ticketingOfficeURL)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MerchandiseDetailView(
        merchandiseList: [
            ConcertMerchandise(id: 1, name: "제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름제품이름", price: "가격", imageURL: nil),
            ConcertMerchandise(id: 2, name: "제품이름", price: "가격", imageURL: nil),
            ConcertMerchandise(id: 3, name: "제품이름", price: "가격", imageURL: nil),
            ConcertMerchandise(id: 4, name: "제품이름", price: "가격", imageURL: nil),
            ConcertMerchandise(id: 5, name: "제품이름", price: "가격", imageURL: nil)
        ],
        ticketingOfficeURL: nil,
        onTicketSiteReturn: {}
    )
}

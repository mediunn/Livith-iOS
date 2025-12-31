//
//  MerchandiseDetailView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct MerchandiseDetailView: View {

    // MARK: - Property

    let merchandiseList: [ConcertMerchandise]
    let onDismiss: () -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 3
    )

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ConcertNavigationBar(
                title: "MD 상세",
                onBack: onDismiss
            )

            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 16, pinnedViews: []) {
                    ForEach(merchandiseList) { merchandise in
                        ThumbnailCard(
                            imageURL: merchandise.imageURL.flatMap { URL(string: $0) },
                            title: merchandise.name,
                            subtitle: merchandise.price,
                            flexible: true
                        )
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
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
        onDismiss: {}
    )
}

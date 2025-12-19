//
//  BannerSectionView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SearchDomain

struct BannerSectionView: View {
	@Binding var currentPage: Int
	let banners: [Banner]

	var body: some View {
		ZStack(alignment: .bottom) {
			TabView(selection: $currentPage) {
				ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
					BannerCell(
						imageURL: banner.imageURL,
						category: banner.category,
						title: banner.title,
						description: banner.description
					)
					.tag(index)
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			.frame(height: 365)

			BannerPageIndicator(
				currentPage: currentPage,
				pageCount: banners.count
			)
			.padding(.bottom, 16)
		}
	}
}

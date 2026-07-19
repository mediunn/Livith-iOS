//
//  CalendarHomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarHomeContentView: View {

    // MARK: - Properties

    @ObservedObject var store: CalendarHomeStore

    @State private var showSelectionBlockedToast = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            CalendarFilterBarView(store: store)

            CalendarWebView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onChange(of: store.state.selectionBlockedToastTrigger) { _, newValue in
            guard newValue > 0 else { return }
            showSelectionBlockedToast = true
        }
        .onDisappear {
            dismissSelectionBlockedToast()
        }
        .livithToast(
            isPresented: selectionBlockedToastBinding,
            type: .failure,
            message: store.state.selectionBlockedToastMessage
        )
    }
}

// MARK: - Computed Properties

private extension CalendarHomeContentView {
    var selectionBlockedToastBinding: Binding<Bool> {
        Binding(
            get: { showSelectionBlockedToast && !store.state.selectionBlockedToastMessage.isEmpty },
            set: { isPresented in
                if !isPresented {
                    dismissSelectionBlockedToast()
                }
            }
        )
    }
}

// MARK: - Actions

private extension CalendarHomeContentView {
    func dismissSelectionBlockedToast() {
        guard showSelectionBlockedToast || !store.state.selectionBlockedToastMessage.isEmpty else { return }

        showSelectionBlockedToast = false
        store.send(.onSelectionBlockedToastDisappear)
    }
}

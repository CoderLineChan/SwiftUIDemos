//
//  View+Extension.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func loadingScreen(states: Binding<Bool>) -> some View {
        self
            .overlay(
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .background(.bar, in: .rect(cornerRadius: 10))
                }
                    .opacity(states.wrappedValue ? 1 : 0)
                    .allowsHitTesting(states.wrappedValue)
                    .animation(snappy, value: states.wrappedValue)
            )
    }
    
    var snappy: Animation {
        .snappy(duration: 0.25, extraBounce: 0)
    }
}

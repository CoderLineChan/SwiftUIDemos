//
//  ContentView.swift
//  DynamicIslandRefreshView
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DynamicIslandRefreshView(showIndicator: true) {
            VStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 300)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(height: 300)
                
            }
                
        } onRefresh: {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate a network delay of 2 seconds
        }
    }
}

#Preview {
    ContentView()
}

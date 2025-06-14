//
//  ContentView.swift
//  PageViewDemo
//
//  Created by CoderChan on 2025/6/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PageView(displassSymbols: false) {
            RoundedRectangle(cornerRadius: 30)
                .fill(.blue.gradient)
                .frame(height: 350)
                .padding()
        } labels: {
            PageLabel(title: "Posts", symbolImage: "square.grid.3x3.fill")
            PageLabel(title: "Reels", symbolImage: "photo.stack.fill")
            PageLabel(title: "Tagged", symbolImage: "person.crop.rectangle")
        } pages: {
            DummyView(.red, count: 20)
            DummyView(.green, count: 40)
            DummyView(.yellow, count: 7)
        } onRefresh: {
            print("Refreshing...")
        }
    }
    
    @ViewBuilder
    private func DummyView(_ color: Color, count: Int) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.gradient)
                    .frame(height: 45)
            }
                    
        }
        .padding(15)
    }
}

#Preview {
    ContentView()
}

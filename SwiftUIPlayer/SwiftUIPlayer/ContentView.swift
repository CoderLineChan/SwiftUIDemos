//
//  ContentView.swift
//  SwiftUIPlayer
//
//  Created by CoderChan on 2025/6/8.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometryProxy in
            let size = geometryProxy.size
            let safeArea = geometryProxy.safeAreaInsets
            PlayerView(size: size, safeArea: safeArea)
                .ignoresSafeArea()
                
        }.preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

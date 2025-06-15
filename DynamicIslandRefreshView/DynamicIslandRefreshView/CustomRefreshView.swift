//
//  CustomRefreshView.swift
//  DynamicIslandRefreshView
//
//  Created by CoderChan on 2025/6/15.
//


import SwiftUI

struct CustomRefreshView<Content: View>: View {
    var showIndicator: Bool
    var content: Content
    var onRefresh: () async -> ()
    init(showIndicator: Bool, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.showIndicator = showIndicator
        self.onRefresh = onRefresh
    }
    @StateObject var scrollDelegate: ScrollViewModel = .init()
    var body: some View {
        ScrollView(.vertical, showsIndicators: showIndicator) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .scaleEffect(scrollDelegate.isEligible ? 1 : 0.001)
                    .frame(height: scrollDelegate.refreshEableOffset * scrollDelegate.progress)
                    
                content
            }
            .overlay(alignment: .top) {
                ZStack {
                    Image(systemName: "arrow.down")
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .rotationEffect(.init(degrees: scrollDelegate.progress * 180))
                        .opacity(scrollDelegate.isEligible ? 0 : 1)
                        
                    
                    ProgressView()
                        .tint(.white)
                        .frame(width: 38, height: 38)
                        .opacity(scrollDelegate.isEligible ? 1 : 0)
                    
                }
                .frame(width: 38, height: 38)
                .background(.primary, in: Circle())
                .animation(.easeInOut(duration: 0.25), value: scrollDelegate.isEligible)
//                .offset(y: -10)
                .opacity(scrollDelegate.progress)
                
            }
            .offset(coordinateSpace: "Scroll") { offset in
                scrollDelegate.contentOffset = offset
                if !scrollDelegate.isEligible {
                    var progress = offset / scrollDelegate.refreshEableOffset
                    progress = (progress < 0) ? 0 : progress
                    progress = (progress > 1) ? 1 : progress
                    scrollDelegate.scrollOffset = offset
                    scrollDelegate.progress = progress
                }
                if scrollDelegate.isEligible && !scrollDelegate.isRefreshing {
                    scrollDelegate.isRefreshing = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        .coordinateSpace(name: "Scroll")
        .onAppear {
            scrollDelegate.addGesture()
        }
        .onDisappear {
            scrollDelegate.removeGesture()
        }
        .onChange(of: scrollDelegate.isRefreshing) { newValue in
            if newValue {
                Task {
                    await onRefresh()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollDelegate.isRefreshing = false
                        scrollDelegate.isEligible = false
                        scrollDelegate.progress = 0.0
                        scrollDelegate.scrollOffset = 0.0
                    }
                }
            }
        }
    }
        
}



#Preview {
    CustomRefreshView(showIndicator: true) {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(height: 300)
            
            Rectangle()
                .fill(Color.yellow)
                .frame(height: 300)
            
        }
            
    } onRefresh: {
        try? await Task.sleep(nanoseconds: 3_000_000_000) // Simulate a network delay of 2 seconds
    }
}

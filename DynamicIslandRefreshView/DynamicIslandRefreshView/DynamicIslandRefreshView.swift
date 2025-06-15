//
//  DynamicIslandRefreshView.swift
//  DynamicIslandRefreshView
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

struct DynamicIslandRefreshView<Content: View>: View {
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
                    .frame(height: scrollDelegate.refreshEableOffset * scrollDelegate.progress)
                content
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
                    
                }
            }
        }
        .overlay(alignment: .top) {
            ZStack {
                Capsule()
                    .fill(.black)
            }
            .frame(width: scrollDelegate.dynamicIslandFrame.width, height: scrollDelegate.dynamicIslandFrame.height)
            .offset(y: scrollDelegate.dynamicIslandFrame.minY)
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .top) {
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: 10))
                    context.drawLayer { ctx in
                        for index in [1, 2] {
                            if let resolvedView = context.resolveSymbol(id: index) {
                                let y = scrollDelegate.dynamicIslandFrame.minY + scrollDelegate.dynamicIslandFrame.height / 2.0
                                ctx.draw(resolvedView, at: CGPoint(x: size.width / 2.0, y: y))
                            }
                        }
                    }
                } symbols: {
                    CanvasSymbol()
                        .tag(1)
                    
                    CanvasSymbol(isCircle: true)
                        .tag(2)
                }
                .allowsHitTesting(false)
            }
            .overlay(alignment: .top) {
                RefreshView()
                    .offset(y: scrollDelegate.dynamicIslandFrame.minY)
            }
            .ignoresSafeArea()
        }
        .coordinateSpace(name: "Scroll")
        .onAppear {
            scrollDelegate.addGesture()
        }
        .onDisappear {
            scrollDelegate.removeGesture()
        }
        .onChange(of: scrollDelegate.isRefreshing) { newValue in
            print("Refreshing state changed: \(newValue)")
            if newValue {
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await onRefresh()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollDelegate.progress = 0.0
                        scrollDelegate.isEligible = false
                        scrollDelegate.isRefreshing = false
                        scrollDelegate.scrollOffset = 0.0
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func CanvasSymbol(isCircle: Bool = false) -> some View {
        if isCircle {
            // Offset will be -> 150 / 2 = 75
            // circle Radius -> 38 / 2 = 19
            // Total -> 75 + 19 = 95
            let total = scrollDelegate.refreshEableOffset / 2.0 + scrollDelegate.dynamicIslandFrame.height / 2.0
            let contentOffset = scrollDelegate.isEligible ? (scrollDelegate.contentOffset > total ? scrollDelegate.contentOffset : total) : scrollDelegate.scrollOffset
            let offset = scrollDelegate.scrollOffset > 0 ? contentOffset : 0
            let canvasSymbolSize: CGFloat = 47
            let sacale: CGFloat = scrollDelegate.dynamicIslandFrame.height / canvasSymbolSize
            let scaling = (scrollDelegate.progress / 1) * (1 - sacale)
            Circle()
                .fill(.black)
                .frame(width: canvasSymbolSize, height: canvasSymbolSize)
                .scaleEffect(sacale + scaling, anchor: .center)
                .offset(y: offset)
        }else {
            Capsule()
                .fill(.black)
                .frame(width: scrollDelegate.dynamicIslandFrame.width, height: scrollDelegate.dynamicIslandFrame.height)
        }
    }
    
    @ViewBuilder
    func RefreshView() -> some View {
        let total = scrollDelegate.refreshEableOffset / 2.0 + scrollDelegate.dynamicIslandFrame.height / 2.0
        let contentOffset = scrollDelegate.isEligible ? (scrollDelegate.contentOffset > total ? scrollDelegate.contentOffset : total) : scrollDelegate.scrollOffset
        
        let offset = scrollDelegate.scrollOffset > 0 ? contentOffset : 0
        ZStack {
            Image(systemName: "arrow.down")
                .font(.body.bold())
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .rotationEffect(.init(degrees: scrollDelegate.progress * 180))
                .opacity(scrollDelegate.isEligible ? 0 : 1)

            ProgressView()
                .tint(.white)
                .frame(width: 38, height: 38)
                .opacity(scrollDelegate.isEligible ? 1 : 0)
        }
            .animation(.easeInOut(duration: 0.25), value: scrollDelegate.isEligible)
            .opacity(scrollDelegate.progress)
            .offset(y: offset)
            
    }
        
}



class ScrollViewModel: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    @Published var isEligible: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var progress: CGFloat = 0.0
    @Published var contentOffset: CGFloat = 0.0
    @Published var scrollOffset: CGFloat = 0.0
    
    private var isImpact: Bool = false
    let refreshEableOffset: CGFloat = 140
    let dynamicIslandFrame: CGRect = .init(x: 0, y: 14, width: 124, height: 37)
    
    func addGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onChange(gesture:)))
        gesture.name = "PageTabDemoGesture"
        gesture.delegate = self
        rootController().view.addGestureRecognizer(gesture)
    }
    func removeGesture() {
        rootController().view.gestureRecognizers?.removeAll { gesture in
            return gesture.name == "PageTabDemoGesture"
        }
    }
    
    @objc
    func onChange(gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended || gesture.state == .cancelled {
            if scrollOffset >= refreshEableOffset {
                isEligible = true
            } else {
                isEligible = false
            }
            isImpact = false
        }else if gesture.state == .changed {
            if scrollOffset >= refreshEableOffset && !isImpact {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isImpact = true
            }else if scrollOffset < refreshEableOffset && isImpact {
                isImpact = false
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func rootController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = windowScene.windows.last?.rootViewController else {
            return .init()
        }
        return root
    }
    
}

extension View {
    @ViewBuilder
    func offset(coordinateSpace: String, offset : @escaping (CGFloat) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let minY = $0.frame(in: .named(coordinateSpace)).minY
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: minY)
                        .onPreferenceChange(ScrollOffsetKey.self) { value in
                            offset(value)
                        }
                }
            }
    }
}


struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
 


#Preview {
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
        print("Refreshing...")
         // Simulate a network delay of 2 seconds
        print("Refresh completed")
    }
}

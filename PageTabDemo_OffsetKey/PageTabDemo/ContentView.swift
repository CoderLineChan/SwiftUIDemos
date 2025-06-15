//
//  ContentView.swift
//  PageTabDemo
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: DummyTab = .home
    @State private var offsetX: CGFloat = 0
    @State private var isTapped: Bool = false
//    @ObservedObject var interactionManager = InteractionManager()
    var body: some View {
        
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .top) {
                TabView(selection: $activeTab) {
                    ForEach(DummyTab.allCases, id: \.self) { tab in
                        SampleView(tab.color)
                            .tag(tab)
                            .offsetX { value in
                                print("Offset for:\(value)")
                                
                                if activeTab == tab && !isTapped {
                                    offsetX = value - (size.width * CGFloat(indexOf(tab: tab)))
                                }
                                if value == 0 && isTapped {
                                    isTapped = false
                                }
                            }
                            
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.all)
                
                
                TabbarHeaderView(size: size)
                    
            }
            .frame(width: size.width, height: size.height)
            
        }
//        .onChange(of: interactionManager.isInteracting) { newValue in
//            print("Interaction state changed: \(newValue)")
////            offsetX = newValue
//        }
    }
    
    @ViewBuilder
    func SampleView(_ tint: Color) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(0..<50, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(tint)
                        .frame(height: 150)
                        .padding(5)
                }
            }
        }
        
    }
    
    @ViewBuilder
    func TabbarHeaderView(size: CGSize) -> some View {
        VStack {
            Tabbar(size: size, .gray)
                .overlay(alignment: .leading) {
                    GeometryReader { _ in
                        let tabCount = CGFloat(DummyTab.allCases.count)
                        let capsuleWidth = size.width / tabCount
                        let progress = tabOffset(size: size, padding: 0)
                        
                        Capsule()
                            .fill(.black)
                            .frame(width: capsuleWidth)
                            .offset(x: progress)
                        
                        Tabbar(size: size, .white, .semibold)
                            .mask(alignment: .leading) {
                                Capsule()
                                    .frame(width: capsuleWidth)
                                    .offset(x: progress)
                                
                            }
                    }
                }
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .padding(0)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func Tabbar(size: CGSize, _ tint: Color, _ weight: Font.Weight = .regular) -> some View {
        HStack(spacing: 0) {
            ForEach(DummyTab.allCases, id: \.self) { tab in
                Text(tab.rawValue)
                    .font(.callout)
                    .fontWeight(weight)
                    .foregroundColor(tint)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        isTapped = true
                        withAnimation {
//                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            activeTab = tab
                            let x = -size.width * CGFloat(indexOf(tab: tab))
                            print("Offset forXX:\(x)")
                            offsetX = -size.width * CGFloat(indexOf(tab: tab))
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
    func tabOffset(size: CGSize, padding: CGFloat) -> CGFloat {
        return (-offsetX / size.width) * ((size.width - padding) / CGFloat(DummyTab.allCases.count))
    }
    func indexOf(tab: DummyTab) -> Int {
        let index = DummyTab.allCases.firstIndex { CTab in
            CTab == tab
        } ?? 0
        return index
    }
}

#Preview {
    ContentView()
}

class InteractionManager: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    @Published var isGestureAdded: Bool = false
    @Published var isInteracting: Bool = false
    func addGesture() {
        if isGestureAdded {
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let window = windowScene.windows.last?.rootViewController else {
            return
        }
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onChange(gesture:)))
        gesture.name = "PageTabDemoGesture"
        gesture.delegate = self
        window.view.addGestureRecognizer(gesture)
        isGestureAdded = true
    }
    
    func removeGesture() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let window = windowScene.windows.last?.rootViewController else {
            return
        }
        window.view.gestureRecognizers?.removeAll { gesture in
            return gesture.name == "PageTabDemoGesture"
        }
        isGestureAdded = false
    }
    
    @objc
    func onChange(gesture: UIPanGestureRecognizer) {
        isInteracting = gesture.state == .changed
        
       
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension View {
    @ViewBuilder
    func offsetX(completion: @escaping (CGFloat) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let minX = $0.frame(in: .global).minX
                    Color.clear
                        .preference(key: PageOffsetKey.self, value: minX)
                        .onPreferenceChange(PageOffsetKey.self) { value in
                            completion(value)
                        }
                }
            }
    }
}
    
struct PageOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
 



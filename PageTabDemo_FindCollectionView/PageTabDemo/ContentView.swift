//
//  ContentView.swift
//  PageTabDemo
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: DummyTab = .home
    var offsetObserver = PageOffsetObserver()
    var body: some View {
        VStack(spacing: 15) {
            Tabbar(.gray)
                .overlay {
                    if let collectionViewBounds = offsetObserver.collectionView?.bounds {
                        GeometryReader {
                            let width = $0.size.width
                            let tabCount = CGFloat(DummyTab.allCases.count)
                            let capsuleWidth = width / tabCount
                            let progress = (offsetObserver.offset / collectionViewBounds.width)
                            
                            Capsule()
                                .fill(.black)
                                .frame(width: capsuleWidth)
                                .offset(x: progress * capsuleWidth)
                            
                            Tabbar(.white, .semibold)
                                .mask(alignment: .leading) {
                                    Capsule()
                                        .frame(width: capsuleWidth)
                                        .offset(x: progress * capsuleWidth)
                                    
                                }
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
                .padding([.horizontal, .top], 15)
            
            TabView(selection: $activeTab) {
                ForEach(DummyTab.allCases, id: \.self) { tab in
                    SampleView(tab.color)
                        .tag(tab)
                        .background {
                            if !offsetObserver.isObserving {
                                FindCollectionView {
                                    offsetObserver.collectionView = $0
                                    offsetObserver.observe()
                                }
                            }
                        }
                }
//                DummyTab.home.color
//                    .tag(DummyTab.home)
//                    .background {
//                        if !offsetObserver.isObserving {
//                            FindCollectionView {
//                                offsetObserver.collectionView = $0
//                                offsetObserver.observe()
//                            }
//                        }
//                    }
//                    
//                DummyTab.chats.color
//                    .tag(DummyTab.chats)
//                
//                DummyTab.calls.color
//                    .tag(DummyTab.calls)
//                
//                DummyTab.settings.color
//                    .tag(DummyTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    @ViewBuilder
    func SampleView(_ tint: Color) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(0..<50, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(tint.gradient)
                        .frame(height: 150)
                        .padding(5)
                }
            }
        }
        
    }
    
    @ViewBuilder
    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular) -> some View {
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
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            activeTab = tab
                        }
                    }
            }
        }
        .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
}


@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGFloat = 0
    private(set) var isObserving: Bool = false
    func observe() {
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
        isObserving = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else {
            return
        }
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset.x
            
        }
        
    }
}
    
struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperView {
                result(collectionView)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var collectionSuperView: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        return superview?.collectionSuperView
    }
}



//
//  PageView.swift
//  PageViewDemo
//
//  Created by CoderChan on 2025/6/14.
//

import SwiftUI


struct PageLabel {
    var title: String
    var symbolImage: String
}

@resultBuilder
struct PageLabelBuider {
    static func buildBlock(_ components: PageLabel...) -> [PageLabel] {
        components.compactMap({ $0 })
    }
}

struct PageView<Header: View, Pages: View>: View {
    var displassSymbols: Bool = false
    var header: Header
    var labels: [PageLabel]
    var pages: Pages
    var onRefresh: () async -> ()
    init(
        displassSymbols: Bool,
        @ViewBuilder header: @escaping () -> Header,
        @PageLabelBuider labels: @escaping () -> [PageLabel],
        @ViewBuilder pages: @escaping () -> Pages,
        onRefresh: @escaping () async -> ()
    ) {
        self.displassSymbols = displassSymbols
        self.header = header()
        self.labels = labels()
        self.pages = pages()
        self.onRefresh = onRefresh
        let count = labels().count
        self._scrollPositions = .init(initialValue: .init(repeating: .init(), count: count))
        self._scrollGeometries = .init(initialValue: .init(repeating: .init(), count: count))
    }
    @State private var activeTab: String? = nil {
        didSet {
            print("Active Tab Changed: \(activeTab ?? "None")")
        }
    }
    @State private var headerHeight: CGFloat = 0
    @State private var scrollGeometries: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]
    @State private var mainScrollDisabled: Bool = false
    @State private var mainScrollPhase: ScrollPhase = .idle
    @State private var mainScrollGeometry: ScrollGeometry = .init()
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    Group(subviews: pages) { collection in
                        if collection.count != labels.count {
                            Text("Error: Number of pages does not match number of labels")
                                .frame(width: size.width, height: size.height)
                        }else {
                            ForEach(labels, id: \.title) { label in
                                PageScrollView(label: label, size: size, collection: collection)
                                    
                            }
                        }
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeTab)
            .scrollIndicators(.hidden)
            .scrollDisabled(mainScrollDisabled)
            .allowsHitTesting(mainScrollPhase == .idle)
            .onScrollPhaseChange({ oldPhase, newPhase in
                mainScrollPhase = newPhase
                if newPhase == .idle {
                    let pageWidth = mainScrollGeometry.contentSize.width / CGFloat(labels.count)
                    guard pageWidth > 0 else { return }
                    let pageIndex = Int(round(mainScrollGeometry.offsetX / pageWidth))
                    if labels.indices.contains(pageIndex) {
                        let newTab = labels[pageIndex].title
                        if activeTab != newTab {
                            activeTab = newTab
                        }
                    }
                }
            })
            .onScrollGeometryChange(for: ScrollGeometry.self, of: {
                $0
            }, action: { oldValue, newValue in
                mainScrollGeometry = newValue
            })
            .mask{
                Rectangle()
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onAppear {
                guard activeTab == nil else { return }
                activeTab = labels.first?.title
                
            }
            
        }
    }
    
    @ViewBuilder
    func PageScrollView(label: PageLabel, size: CGSize, collection: SubviewsCollection) -> some View {
        let index = labels.firstIndex(where: { $0.title == label.title }) ?? 0
        ScrollView(.vertical) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ZStack {
                    if label.title == labels[currentVisibleIndex].title || activeTab == label.title {
                        header
                            .visualEffect({ content, proxy in
                                content
                                    .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                            })
                            .onGeometryChange(for: CGFloat.self, of: {
                                $0.size.height
                            }) { newValue in
                                headerHeight = newValue
                            }
                            .transition(.identity)
                    }else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: headerHeight)
                            .transition(.identity)
                    }
                }
                .simultaneousGesture(horizontalScrollDisableGesture)
            
                Section {
                    collection[index]
                        .frame(minHeight: size.height - 44, alignment: .top)
                        .border(.orange)
                } header: {
                    ZStack {
                        if label.title == labels[currentVisibleIndex].title || activeTab == label.title {
                            PageTabBar()
                                .visualEffect({ content, proxy in
                                    content
                                        .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                                })
                                .transition(.identity)
                        }else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: 44)
                                .transition(.identity)
                        }
                    }
                    .simultaneousGesture(horizontalScrollDisableGesture)
                }
            }
        }
        .onScrollGeometryChange(for: ScrollGeometry.self, of: {
            $0
        }, action: { oldValue, newValue in
            scrollGeometries[index] = newValue
            if newValue.offsetY < 0 {
                resetScrollViews(label)
            }
        })
        .scrollPosition($scrollPositions[index])
        .onScrollPhaseChange({ oldPhase, newPhase in
            let geometry = scrollGeometries[index]
            let maxOffset = min(geometry.offsetY, headerHeight)
            if newPhase == .idle || maxOffset <= headerHeight {
                updateOtherScrollViews(label, to: maxOffset)
            }
            
            if newPhase == .idle && mainScrollDisabled {
                mainScrollDisabled = false
            }
        })
        .frame(width: size.width)
        .scrollClipDisabled()
        .refreshable {
            await onRefresh()
        }
    }
    
    
    @ViewBuilder
    func PageTabBar() -> some View {
        GeometryReader { proxy in
            let tabWidth = proxy.size.width / CGFloat(labels.count)
            let progress = mainScrollGeometry.offsetX / mainScrollGeometry.contentSize.width * CGFloat(labels.count)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(labels.indices, id: \.self) { i in
                        let fade = 1.0 - min(abs(progress - CGFloat(i)), 1.0)
                        let color = Color.primary.opacity(0.5 + 0.5 * fade)
                        Group {
                            if displassSymbols {
                                Label(labels[i].title, systemImage: labels[i].symbolImage)
                                    .font(.headline)
                                    .foregroundColor(color)
                            } else {
                                Text(labels[i].title)
                                    .font(.headline)
                                    .foregroundColor(color)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                activeTab = labels[i].title
                            }
                        }
                    }
                }
                Capsule()
                    .frame(width: 50, height: 4)
                    .containerRelativeFrame(.horizontal) { (value, _) in
                        return value / CGFloat(labels.count)
                    }
                    .visualEffect { content, proxy in
                        content
                            .offset(x: proxy.size.width * progress)
                    }
                
            }
            .frame(height: 44) // Fixed total height
            .background(.background)
        }
        .frame(height: 44)
        .background(.background)
    }
    
    var horizontalScrollDisableGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                mainScrollDisabled = true
            }
            .onEnded { _ in
                mainScrollDisabled = false
            }
    }
    
    func resetScrollViews(_ from: PageLabel) {
        for index in labels.indices {
            let label = labels[index]
            if label.title != from.title {
                scrollPositions[index].scrollTo(y: 0)
            }
        }
    }
    
    func updateOtherScrollViews(_ from: PageLabel, to: CGFloat) {
        for index in labels.indices {
            let label = labels[index]
            let offset = scrollGeometries[index].offsetY
            let wantsUpdate = offset < headerHeight || to < headerHeight
            if wantsUpdate && label.title != from.title {
                scrollPositions[index].scrollTo(y: to)
            }
        }
    }
    
    private var currentVisibleIndex: Int {
        let pageWidth = mainScrollGeometry.contentSize.width / CGFloat(labels.count)
        guard pageWidth > 0 else { return 0 }
        let index = Int(round(mainScrollGeometry.offsetX / pageWidth))
        return labels.indices.contains(index) ? index : 0
    }
}

#Preview {
    ContentView()
}


extension ScrollGeometry {
    init() {
        self.init(contentOffset: .zero, contentSize: .zero, contentInsets: .init(.zero), containerSize: .zero)
    }
    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }
    var offsetX: CGFloat {
        contentOffset.x + contentInsets.leading
    }
}

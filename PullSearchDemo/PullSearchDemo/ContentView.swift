//
//  ContentView.swift
//  PullSearchDemo
//
//  Created by CoderChan on 2025/6/14.
//

import SwiftUI

struct ContentView: View {
    @State private var offsetY: CGFloat = 0
    @FocusState private var isExpanded: Bool
    var body: some View {
        ScrollView(.vertical) {
            ScrollCcontent()
                .onGeometryChange(for: CGFloat.self) { geometry in
                    geometry.frame(in: .scrollView(axis: .vertical)).maxY
                } action: { newValue in
                    offsetY = newValue
                    let pro = max(min((offsetY - 200) / 100, 1), 0)
                    print("Offset Y: \(offsetY), Progress:\(pro)")
                }

        }
        .overlay{
            Rectangle()
                .fill(.ultraThinMaterial)
                .background(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .overlay {
                    ExpandedSearchResultView(isExpanded: isExpanded)
                        .opacity(isExpanded ? 1 : 0)
                        .allowsHitTesting(isExpanded)
                }
                .opacity(isExpanded ? 1 : progress)
                
        }
        .safeAreaInset(edge: .top) {
            HeaderView()
        }
        .scrollTargetBehavior(OnScrollEnd { dy in
            print("Scroll ended with velocity: \(dy), offset: \(offsetY)")
            if offsetY > 300 || (-dy > 1.5 && offsetY > 0) {
                isExpanded = true
            }
        })
        
        .animation(.interpolatingSpring(duration: 0.2), value: isExpanded)
    }
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack(spacing: 20) {
            if  !isExpanded {
                Button {
                    
                } label: {
                    Image(systemName: "slider.horizontal.below.square.filled.and.square")
                        .font(.title3)
                    
                }
            }
            TextField("Search App", text: .constant(""))
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            
                    }
                    .clipShape(.rect(cornerRadius: 15))
                }
                .focused($isExpanded)

            Button {
                
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    
            }
            .opacity(isExpanded ? 0 : 1)
            .overlay(alignment: .trailing) {
                Button("cancel") {
                    isExpanded = false
                }
                .fixedSize()
                .opacity(isExpanded ? 1 : 0)
            }
            .padding(.leading, isExpanded ? 20 : 0)

        }
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 5)
        .background {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func ScrollCcontent() -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 30) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red.gradient)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.orange.gradient)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.brown.gradient)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.green.gradient)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.yellow.gradient)
                    
            }
            .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 25) {
                Text("List")
                    .foregroundStyle(.gray)
                
                Text("Start adding your first item to the list")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    
            }
            .padding(.top, 30)
            
            
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
    }
    
    var progress: CGFloat {
        return max(min((offsetY - 200) / 100, 1), 0)
    }
}

#Preview {
    ContentView()
}


struct OnScrollEnd: ScrollTargetBehavior {
    var onEnd: (CGFloat) -> ()
    func updateTarget(_ target: inout ScrollTarget, context : TargetContext) {
        let dy = context.velocity.dy
        DispatchQueue.main.async {
            onEnd(dy)
        }
    }
}

struct ExpandedSearchResultView: View {
    var isExpanded: Bool
    var body: some View {
        List {
            let colors: [Color] = [.black, .indigo, .cyan]
            if isExpanded {
                ForEach(colors, id: \.self) { color in
                    Section(String.init(describing: color).capitalized) {
                        ForEach (0..<10, id: \.self) { index in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(color.gradient)
                                    .frame(width: 50, height: 50)
                                
                                Text("Item \(index)")
                                
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 12, leading: 0, bottom: 12, trailing: 0))
                    
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .clipped()
    }
}

//
//  ContentView.swift
//  PopToRootAppDemo
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: Tab = .home
    @State private var homeStackPath = NavigationPath()
    @State private var settingsStackPath = NavigationPath()
    @State private var tabCount: Int = .zero
    var body: some View {
        TabView(selection: tabSelection) {
            NavigationStack(path: $homeStackPath) {
                List {
                    NavigationLink("Detail", value: "Detail")
                }
                .navigationTitle("Home")
                .navigationDestination(for: String.self) { value in
                    List {
                        if value == "Detail" {
                            NavigationLink("more", value: "more")
                        }
                    }
                    .navigationTitle(value)
                }
            }
            .tag(Tab.home)
            .tabItem {
                Image(systemName: Tab.home.symbolImage)
                Text(Tab.home.rawValue)
            }
            
            NavigationStack(path: $settingsStackPath) {
                List {
                    
                }
                .navigationTitle("settings")
            }
            .tag(Tab.settings)
            .tabItem {
                Image(systemName: Tab.settings.symbolImage)
                Text(Tab.settings.rawValue)
            }
                
        }
    }
    
    var tabSelection: Binding<Tab> {
        return .init {
            return activeTab
        } set: { newValue in
            if newValue == activeTab {
                tabCount += 1
                if tabCount == 2 {
                    switch newValue {
                    case .home:
                        homeStackPath = NavigationPath() // Pop to root
                    case .settings:
                        settingsStackPath = NavigationPath() // Pop to root
                    }
                    tabCount = .zero
                }
            }else {
                tabCount = .zero
            }
            activeTab = newValue
        }

    }
}

#Preview {
    ContentView()
}


enum Tab: String {
    case home = "Home"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

}

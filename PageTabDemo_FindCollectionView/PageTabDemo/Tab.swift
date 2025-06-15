//
//  Tab.swift
//  PageTabDemo
//
//  Created by CoderChan on 2025/6/15.
//

import SwiftUI

enum DummyTab: String, CaseIterable {
    case home = "Home"
    case chats = "Chats"
    case calls = "Calls"
    case settings = "Settings"
    
    var color: Color {
        switch self {
        case .home:
            return .blue
        case .chats:
            return .green
        case .calls:
            return .orange
        case .settings:
            return .purple
        }
    }
}

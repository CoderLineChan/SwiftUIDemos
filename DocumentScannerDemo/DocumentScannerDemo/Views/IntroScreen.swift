//
//  IntroScreen.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI


struct IntroScreen: View {
    @AppStorage("showIntroView") private var showIntroView: Bool = true
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Welcome to Document Scanner")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 65)
                .padding(.bottom, 35)
            
            
            VStack(alignment: .leading, spacing: 25) {
                PointView(title: "Scan Documents", image: "scanner", description: "Scan any document with your camera and convert it into a digital format.")
                
                PointView(title: "Save Documents", image: "tray.full.fill", description: "Persist scanned documents with the new SwiftData model.")
                
                
                PointView(title: "Lock Documents", image: "faceid", description: "Persist your documents securely with Face ID or Touch ID.")
            }
            .padding(.horizontal, 15)
            Spacer(minLength: 0)
            
            Button {
                showIntroView = false
            } label: {
                Text("Start using document Scanner")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.purple.gradient, in: .capsule)
                    
            }

            
        }
        .padding(15)
    }
    
    @ViewBuilder
    private func PointView(title: String, image: String, description: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundColor(.purple)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.gray)
                
            }
        }
    }
}

#Preview {
    IntroScreen()
}

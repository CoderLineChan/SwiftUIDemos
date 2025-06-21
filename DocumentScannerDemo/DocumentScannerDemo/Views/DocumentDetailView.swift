//
//  DocumentDetailView.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI
import PDFKit
import LocalAuthentication

struct DocumentDetailView: View {
    var document: Document
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isLoading: Bool = false
    @State private var showFileMover: Bool = false
    @State private var fileURL: URL? = nil
    @State private var isLockAvailable: Bool?
    @State private var isUnlocked: Bool = false
    
    var body: some View {
        if let pages = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex }) {
            VStack(spacing: 10) {
                HeaderView()
                    .padding([.horizontal, .top], 15)
                TabView {
                    ForEach(pages) { page in
                        if let image = UIImage(data: page.pageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Text("Image not available")
                                .foregroundColor(.red)
                        }
                    }
                }
                .tabViewStyle(.page)
                
                FooterView()
            }
            .background(.black)
            .toolbarVisibility(.hidden, for: .navigationBar)//iOS18
            .loadingScreen(states: $isLoading)
            .overlay {
                LockView()
            }
            .fileMover(isPresented: $showFileMover, file: fileURL) { result in
                if case .failure(_) = result {
                    guard let fileURL else { return }
                    print("Failed to move file to destination.")
                    try? FileManager.default.removeItem(at: fileURL)
                    self.fileURL = nil
                }
            }
            .onAppear {
                guard document.isLocked else {
                    isUnlocked = true
                    return
                }
                let context = LAContext()
                isLockAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            }
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        Text(document.name)
            .font(.callout)
            .foregroundStyle(.white)
            .hSpacing(.center)
            .overlay(alignment: .trailing) {
                Button {
                    document.isLocked.toggle()
                    isUnlocked = !document.isLocked
                    try? modelContext.save()
                } label: {
                    Image(systemName: document.isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.title3)
                        .foregroundStyle(.purple)
                }
            }
    }
    
    @ViewBuilder
    private func FooterView() -> some View {
        HStack(spacing: 10) {
            Button {
                // Handle delete action
                dismiss()
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.3))
                    modelContext.delete(document)
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
            Spacer()
            Button(action: createAndShareDocument) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding([.horizontal, .bottom], 15)
    }
    
    @ViewBuilder
    private func LockView() -> some View {
        if document.isLocked {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 6) {
                    if let isLockAvailable, !isLockAvailable {
                        Text("Face ID or Touch ID is not available on this device.")
                            .multilineTextAlignment(.center)
                            .frame(width: 200)
                    }else {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                        
                        Text("Tap to unlock!")
                            .font(.callout)
                    }
                }
                .padding(15)
                .background(.bar, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
                .onTapGesture {
                    authenticateUser()
                }
            }
            .opacity(isUnlocked ? 0 : 1)
            .animation(snappy, value: isUnlocked)
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Document") { success, error in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = success
                        document.isLocked = false
                        try? modelContext.save()
                    } else {
                        print("Authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            isLockAvailable = false
            isUnlocked = false
        }
    }
    
    private func createAndShareDocument() {
        guard let pages = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex }) else {
            return
        }
        isLoading = true
        Task.detached(priority: .high) { [document] in
            let pdfDocument = PDFDocument()
            for index in pages.indices {
                if let pageImage = UIImage(data: pages[index].pageData),
                   let pdfPage = PDFPage(image: pageImage) {
                    pdfDocument.insert(pdfPage, at: index)
                }
            }
            
            var pdfURL = FileManager.default.temporaryDirectory
            let fimeName = "\(document.name).pdf"
            pdfURL.appendPathComponent(fimeName)
            
            if pdfDocument.write(to: pdfURL) {
                await MainActor.run { [pdfURL] in
                    fileURL = pdfURL
                    showFileMover = true
                    isLoading = false
                }
            }
        }
        
    }
}


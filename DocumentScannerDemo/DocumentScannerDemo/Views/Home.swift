//
//  Home.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI
import SwiftData
import VisionKit

struct Home: View {
    @Query(sort: [.init(\Document.createdAt, order: .reverse)], animation: .snappy(duration: 0.25, extraBounce: 0))
    private var documents: [Document]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showScannerView: Bool = false
    @State private var documentName: String = "New Document"
    @State private var askDocumentName: Bool = false
    @State private var scanDocument: VNDocumentCameraScan?
    @State private var isLoading: Bool = false
    @Namespace private var animationID
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2), spacing: 15) {
                    ForEach(documents) { document in
                        NavigationLink {
                            DocumentDetailView(document: document)
                                .navigationTransition(.zoom(sourceID: document.uniqueViewID, in: animationID))//iOS18
                        } label: {
                            DocumentCardView(document: document, animationID: animationID)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
                .padding(15)
            }
            .navigationTitle("Document's")
            .safeAreaInset(edge: .bottom) {
                createButton()
            }
            .fullScreenCover(isPresented: $showScannerView) {
                ScannerView { error in
                    
                } didCancel: {
                    showScannerView = false
                } didFinish: { scan in
                    print("Scan finished: \(scan)")
                    scanDocument = scan
                    showScannerView = false
                    askDocumentName = true
                }
                .ignoresSafeArea()
                
            }
            .alert("Document Name", isPresented: $askDocumentName) {
                TextField("Enter Document Name", text: $documentName)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                
                Button("Save") {
                    createDocument()
                }
                .disabled(documentName.isEmpty)
                
            }
            .loadingScreen(states: $isLoading)
        }
        .onAppear {
            print("Documents count: \(documents.count)")
        }
    }
    
    @ViewBuilder
    func createButton() -> some View {
        Button {
            showScannerView.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "document.viewfinder.fill")
                    .font(.title3)
                
                Text("Scan Documents")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.purple.gradient, in: .capsule)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(.linearGradient(colors: [
                            .white.opacity(0),
                            .white.opacity(0.5),
                            .white,
                            .white
                        ], startPoint: .top, endPoint: .bottom))
                }
                .ignoresSafeArea()
        }
        
    }
    
    func createDocument() {
        guard let scanDocument else {
            return
        }
        isLoading = true
        Task.detached(priority: .high) { [documentName] in
            let document = Document(name: documentName)
            var pages: [DocumentPage] = []
            for pageIndex in 0..<scanDocument.pageCount {
                let pageImage = scanDocument.imageOfPage(at: pageIndex)
                guard let pageData = pageImage.jpegData(compressionQuality: 0.65) else { return }
                
                let documentPage = DocumentPage(document: document, pageIndex: pageIndex, pageData: pageData)
                pages.append(documentPage)
            }
            
            document.pages = pages
            await MainActor.run {
                modelContext.insert(document)
                try? modelContext.save()
                self.scanDocument = nil
                isLoading = false
                self.documentName = "New Document"
            }
        }
    }
    
}

#Preview {
    ContentView()
}

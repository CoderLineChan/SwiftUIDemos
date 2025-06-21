//
//  DocumentCardView.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI

struct DocumentCardView: View {
    var document: Document
    var animationID: Namespace.ID
    @State private var downsizedImage: UIImage?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            if let firstPage = document.pages?.sorted(by: { $0.pageIndex < $1.pageIndex }).first {
                GeometryReader {
                    let size = $0.size
                    // 内存占用更大
//                    if let image = UIImage(data: firstPage.pageData) {
//                        Image(uiImage: image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: size.width, height: size.height)
//                            
//                    }
                    if let downsizedImage {
                        Image(uiImage: downsizedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .task(priority: .high) {
                                guard let image = UIImage(data: firstPage.pageData) else { return }
                                let aspectSize = image.size.aspecFit(.init(width: 150, height: 150))
                                let renderer = UIGraphicsImageRenderer(size: aspectSize)
                                let resizedImage = renderer.image { context in
                                    image.draw(in: CGRect(origin: .zero, size: aspectSize))
                                }
                                await MainActor.run {
                                    downsizedImage = resizedImage
                                }
                            }
                    }
                    
                    if document.isLocked {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                //iOS 18 API
                .matchedTransitionSource(id: document.uniqueViewID, in: animationID)
            }
            
            Text(document.name)
                .font(.headline)
                .lineLimit(1)
                .padding(.top, 10)
            
            Text(document.createdAt.formatted(date: .numeric, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.gray)
                
                
        }
        
    }
}

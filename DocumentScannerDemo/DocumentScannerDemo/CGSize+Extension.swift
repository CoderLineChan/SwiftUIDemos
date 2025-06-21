//
//  CGSize+Extension.swift
//  DocumentScannerDemo
//
//  Created by CoderChan on 2025/6/21.
//

import SwiftUI

extension CGSize {
    func aspecFit(_ to: CGSize) -> CGSize {
        let widthRatio = to.width / self.width
        let heightRatio = to.height / self.height
        
        let ratio = min(widthRatio, heightRatio)
        
        return CGSize(width: self.width * ratio, height: self.height * ratio)
    }
}

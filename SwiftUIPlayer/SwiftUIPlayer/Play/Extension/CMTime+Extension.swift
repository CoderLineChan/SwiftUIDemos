//
//  CMTime+Extension.swift
//  SwiftUIPlayer
//
//  Created by CoderChan on 2025/6/8.
//

import SwiftUI
import AVKit


extension CMTime {
    func toTimeString() -> String {
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = Int((roundedSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let sec: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, min, sec)
        
        }else {
            return String(format: "%02d:%02d", min, sec)
        }
    }
}

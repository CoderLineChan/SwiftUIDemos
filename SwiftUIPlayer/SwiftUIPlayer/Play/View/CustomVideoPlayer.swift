//
//  CustomVideoPlayer.swift
//  SwiftUIPlayer
//
//  Created by CoderChan on 2025/6/8.
//

import SwiftUI
import AVKit

struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    var player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        
        return playerViewController
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
    

//
//  PlayerView.swift
//  SwiftUIPlayer
//
//  Created by CoderChan on 2025/6/8.
//

import SwiftUI
import AVKit


struct PlayerView: View {
    let size: CGSize
    let safeArea: EdgeInsets
    @State private var player: AVPlayer? = {
        if let bundle = Bundle.main.path(forResource: "PreviewUIKit", ofType: "mov") {
            return AVPlayer(url: URL(fileURLWithPath: bundle))
        }
        return nil
    }()
    @State private var showPlayerControls: Bool = false
    @State private var isPlaying: Bool = false
    @State private var timeoutTask: DispatchWorkItem?
    @State private var isFinishedPlaying: Bool = false
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastGraggedProgress: CGFloat = 0
    @State private var isObserverAdded: Bool = false
    @State private var thumbanilFrames: [UIImage] = []
    @State private var draggingImage: UIImage?
    @State private var playerStatusObserver: NSKeyValueObservation?
    @State private var isRotated: Bool = false
    var body: some View {
        VStack {
            let videoSize = CGSize(width: isRotated ? size.height : size.width, height: isRotated ? size.width : (size.height / 3.5))
            ZStack {
                if let player = player {
                    CustomVideoPlayer(player: player)
                        .border(.orange)
                        .overlay {
                            Rectangle()
                                .fill(Color.black.opacity(0.4))
                                .opacity(showPlayerControls || isDragging ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: isDragging)
                                .overlay {
                                    PlayBackControls()
                                }
                        }
                        .overlay(content: {
                            HStack(spacing: 60) {
                                DoubleTapSeek(isForward: false) {
                                    let seconds = player.currentTime().seconds - 15
                                    player.seek(to: .init(seconds: seconds, preferredTimescale: 600))
                                }
                                
                                DoubleTapSeek(isForward: true) {
                                    let seconds = player.currentTime().seconds + 15
                                    player.seek(to: .init(seconds: seconds, preferredTimescale: 600))
                                }
                            }
                        })
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showPlayerControls.toggle()
                            }
                            if isPlaying {
                                timeoutControls()
                            }
                        }
                        .overlay(alignment: .bottomLeading, content: {
                            SeekerThumbnailView(videoSize)
                                .offset(y: isRotated ? -85 : -60)
                        })
                        .overlay(alignment: .bottom) {
                            VideoSeekerView(videoSize)
                                .offset(y: isRotated ? -15 : 0)
                        }
                }
            }
            .background(content: {
                Rectangle()
                    .fill(Color.black)
                    .padding(.trailing, isRotated ? -safeArea.bottom : 0)
                    .padding(.leading, isRotated ? -safeArea.top : 0)
            })
            .gesture(
                //手势旋转
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 100 {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isRotated = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isRotated = false
                            }
                        }
                    })
            )
            .frame(width: videoSize.width, height: videoSize.height)
            .frame(width: size.width, height: size.height / 3.5, alignment: .bottomLeading)
            .offset(y: isRotated ? -((size.width / 2) + safeArea.bottom / 2) : 0)
            .rotationEffect(.init(degrees: isRotated ? 90 : 0), anchor: .topLeading)
            .zIndex(1000)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(0..<100 , id: \.self) { index in
                        GeometryReader { geometryProxy in
                            let size = geometryProxy.size
                            Color.orange
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            .padding(.bottom, safeArea.bottom)
                
        }
        
        .padding(.top, safeArea.top)
        
        .onAppear {
            guard !isObserverAdded else { return }
            player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 600), queue: .main) { time in
                if let currentPlayerItem = player?.currentItem {
                    let totalDuration = currentPlayerItem.duration.seconds
                    guard let currentDuration = player?.currentTime().seconds else { return }
                    let calculatedProgress = currentDuration / totalDuration
                    if !isSeeking {
                        progress = calculatedProgress
                        lastGraggedProgress = progress
                    }
                    print("calculatedProgress: \(calculatedProgress)")
                    if calculatedProgress == 1 {
                        isFinishedPlaying = true
                        isPlaying = false
                        withAnimation(.easeInOut(duration: 0.35)) {
                            showPlayerControls = true
                        }
                    }
                }
            }
            isObserverAdded = true
            
            playerStatusObserver = player?.currentItem?.observe(\.status, options: [.new]) { item, change in
                if item.status == .readyToPlay {
                    print("Player is ready to play")
                    generateThumbnailFrames()
                }
            }
        }
        .onDisappear {
            playerStatusObserver?.invalidate()
        }
    }
    
    @ViewBuilder
    func SeekerThumbnailView(_ videoSize: CGSize) -> some View {
        let thumbSize = CGSize(width: 175, height: 100)
        ZStack {
            if let draggingImage {
                Image(uiImage: draggingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(alignment: .bottom) {
                        if let currentItem = player?.currentItem {
                            Text(CMTime(seconds: progress * currentItem.duration.seconds, preferredTimescale: 600).toTimeString())
                                .font(.caption)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .offset(y: 15)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    }
            }else {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    }
            }
        }
        .frame(width: thumbSize.width, height: thumbSize.height)
        .opacity(isDragging ? 1 : 0)
        .offset(x: progress * (videoSize.width - thumbSize.width))
    }
    
    @ViewBuilder
    func VideoSeekerView(_ videoSize: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray)
            
            Rectangle()
                .fill(Color.red)
                .frame(width: max(videoSize.width * progress, 0))
        }
        .frame(height: 3)
        .overlay(alignment: .leading) {
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15)
                .scaleEffect(showPlayerControls || isDragging ? 1 : 0.001, anchor: .center)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .offset(x: videoSize.width * progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            if let timeoutTask {
                                timeoutTask.cancel()
                            }
                            
                            let translationX: CGFloat = value.translation.width
                            let calulatedProgress = (translationX / videoSize.width) + lastGraggedProgress
                            progress = max(min(calulatedProgress, 1), 0)
                            
                            isSeeking = true
                            
                            let dragIndex = Int(progress / 0.01)
                            if thumbanilFrames.indices.contains(dragIndex) {
                                draggingImage = thumbanilFrames[dragIndex]
                            }
                        })
                        .onEnded({ value in
                            lastGraggedProgress = progress
                            if let currentPlayerItem = player?.currentItem {
                                let totalDuration = currentPlayerItem.duration.seconds
                                player?.seek(to: .init(seconds: totalDuration * progress, preferredTimescale: 600))
                            }
                             
                            if isPlaying {
                                timeoutControls()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isSeeking = false
                            }
                            isSeeking = false
                            
                            if progress != 1 {
                                isFinishedPlaying = false
                            }
                        })
                )
                .offset(x: progress * videoSize.width > 15 ? -15 : 0)
                .frame(width: 15, height: 15)
        }
    }
    
    @ViewBuilder
    func PlayBackControls() -> some View {
        HStack(spacing: 25) {
            Button {
                
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                    }
            }
            .disabled(true)
            .opacity(0.6)
            
            Button {
                if isFinishedPlaying {
                    isFinishedPlaying = false
                    player?.seek(to: .zero)
                    progress = 0
                    lastGraggedProgress = .zero
                }
                
                if isPlaying {
                    player?.pause()
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                } else {
                    player?.play()
                    timeoutControls()
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: isFinishedPlaying ? "arrow.clockwise" : (isPlaying ? "pause.fill" : "play.fill"))
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                    }
            }
            .scaleEffect(1.1)
            
            Button {
                
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                    }
            }
            .disabled(true)
            .opacity(0.6)

        }
        .opacity(showPlayerControls && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: showPlayerControls && !isDragging)
    }
    
    func timeoutControls() {
        if let timeoutTask {
            timeoutTask.cancel()
        }
        timeoutTask = .init(block: {
            withAnimation(.easeInOut(duration: 0.35)) {
                showPlayerControls = false
            }
        })
        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: timeoutTask)
        }
    }
    
    func generateThumbnailFrames() {
        Task.detached {
            guard let asset = await player?.currentItem?.asset else { return }
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 250, height: 250)
            do {
                let totalDuration = try await asset.load(.duration).seconds
                var frameTimes: [CMTime] = []
                for progress in stride(from: 0, to: 1, by: 0.01) {
                    let time = CMTime(seconds: totalDuration * progress, preferredTimescale: 600)
                    frameTimes.append(time)
                }
                for await result in generator.images(for: frameTimes) {
                    let cgImage = try result.image
                    await MainActor.run {
                        thumbanilFrames.append(UIImage(cgImage: cgImage))
                    }
                }
                    
            }catch {
                print("Error generating thumbnail frames: \(error.localizedDescription)")
            }
        }
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

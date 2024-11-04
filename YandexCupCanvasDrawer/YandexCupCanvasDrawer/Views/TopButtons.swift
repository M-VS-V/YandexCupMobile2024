//
//  TopButtons.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import SwiftUI
import Combine

struct FrameRateButtons: View {
    @Binding var selectedFrameRate: Int

    let frameRates: [Int] = [1, 5, 10, 24, 30, 60, 120]

    var body: some View {
        HStack(spacing: 5) {
            Text("FPS: ").foregroundColor(.white)
            ForEach(frameRates, id: \.self) { frameRate in
                Button(action: {
                    selectedFrameRate = frameRate
                }) {
                    Text("\(frameRate)")
                        .foregroundColor(.white)
                        .font(.system(size: 16.0))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .background(selectedFrameRate == frameRate ? Color.white.opacity(0.3) : Color.clear)
                        .cornerRadius(5)
                }
            }
        }
    }
}

struct TopButtons: View {
    @ObservedObject var appModel: AppModel
    @State private var showImageGallery = false
    let middleTopButtonSize: CGFloat = 24
    let disabledOpacity: CGFloat = 0.5

    var body: some View {
        HStack(spacing: 10) {
            if appModel.isPlaying {
                FrameRateButtons(selectedFrameRate: $appModel.frameRate)
            } else {

                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Button(action: { appModel.activeModel.undo() }) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : (appModel.activeModel.canUndo ? 1.0 : disabledOpacity))
                    }
                    .disabled(!appModel.activeModel.canUndo)

                    Button(action: { appModel.activeModel.redo() }) {
                        Image(systemName: "arrow.uturn.forward")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : (appModel.activeModel.canRedo ? 1.0 : disabledOpacity))
                    }.disabled(!appModel.activeModel.canRedo)

                    Spacer(minLength: 5)
                    Button(action: { appModel.exportGif() }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }
                    Button(action: { appModel.onCopyButtonTapped() }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }
                    Button(action: { appModel.editorMode = .isShowingFrameGenerationMenu }) {
                        Image(systemName: "video")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }
                    Button(action: { appModel.removeFrame() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }
                    Button(action: { appModel.removeAllFrames() }) {
                        Image(systemName: "trash.circle")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }

                    Button(action: {appModel.onNewFrameButtonTapped() }) {
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }
                    Button(action: { showImageGallery = true }) {
                        Image(systemName: "square.3.stack.3d")
                            .foregroundColor(.white)
                            .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                            .opacity(appModel.isPlaying ? 0.0 : 1.0)
                    }.sheet(isPresented: $showImageGallery) {
                        ImageGalleryView(appModel: appModel, images: appModel.images)
                    }
                }
            }
            HStack {
                Button(action: { appModel.stopPlaying() }) {
                    Image(systemName: "pause")
                        .foregroundColor(.white)
                        .opacity(appModel.isPlaying ? 1.0 : disabledOpacity)
                        .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                        .disabled(appModel.editorMode != .playing)
                }
                Button(action: { appModel.startPlaying() }) {
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .frame(width: middleTopButtonSize, height: middleTopButtonSize)
                        .opacity(appModel.isPlaying ? 0.0 : 1.0)
                }
                if !appModel.isPlaying {
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

//
//  AppModel.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation
import Combine
import SwiftUI

enum EditorMode {
    case isShowingLineWidthMenu
    case isShowingFigureChoosingMenu
    case isShowingFrameGenerationMenu
    case normal
    case playing
}

extension AppModel {
    var totalFrames: String {
        let index = editorMode == .playing ? currentFrameIndex : activeModelIndex
        return "Номер кадра \(index + 1)/\(frameModels.count)"
    }

    var images: [UIImage] {
        frameModels.map { $0.image ?? UIImage() }
    }
}

struct DrawingSettingsImpl: DrawingSettings {
    var colorFactory: () -> Color
    var currentColor: Color { colorFactory()}

    var lineWidthFactory: () -> CGFloat
    var lineWidth: CGFloat { lineWidthFactory() }

    var drawingModeFactory: () -> DrawingMode
    var drawingMode: DrawingMode { drawingModeFactory() }
}


class AppModel: ObservableObject {
    @Published var currentColor: Color = .black
    @Published var lineWidth: CGFloat = 3
    @Published var editorMode: EditorMode = .normal
    @Published var drawingMode: DrawingMode = .draw
    var isPlaying: Bool { editorMode == .playing }
    @Published var currentFrameIndex: Int = 0
    // Частота кадров (например, 10 кадров в секунду)
    @Published var frameRate: Int = 24 {
        didSet {
            if editorMode.isPlaying {
                invalidateAndStartTimer()
            }
        }
    }
    @Published var drawingViewSize: CGSize = .zero

    var previousFrameImage: UIImage? {
        let index = activeModelIndex - 1
        guard index >= 0 else { return nil }
        return frameModels[index].image
    }

    var activeModel: DrawingModel { frameModels[activeModelIndex] }

    init() {
        let model = DrawingModel(settings: drawingSettings)
        frameModels = [model]
        setupActiveModelObserver()
    }

    @Published private var activeModelIndex = 0 {
        didSet {
            cancellables.forEach { $0.cancel() }
            setupActiveModelObserver()
        }
    }

    private lazy var drawingSettings: DrawingSettings = {
        return DrawingSettingsImpl(
            colorFactory: { [weak self] in self?.currentColor ?? .black },
            lineWidthFactory: { [weak self] in self?.lineWidth ?? 3 },
            drawingModeFactory: { [weak self] in self?.drawingMode ?? .draw }
        )
    }()

    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    private var frameModels: [DrawingModel] = []
}

extension DrawingModel {
    func getImage(size: CGSize) -> UIImage {
        DrawingView(model: self, mode: .showPreviousImage(nil)).asImage(size: size)
    }
}

extension AppModel {

    func exportGif() {
        exportImagesToGIF(images: images) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fileURL):
                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        rootViewController.present(activityViewController, animated: true, completion: nil)
                    }
                case .failure(let error):
                    print("Error exporting GIF: \(error.localizedDescription)")
                }
            }
        }
    }

    func routeToImage(at index: Int) {
        activeModelIndex = index
    }

    func onNewFrameButtonTapped() {
        generateNewFrameSavingActiveModel()
    }

    func onGenerateFramesButtonTap(framesNumber: Int) {
        for _ in 0..<framesNumber {
            autoreleasepool {
                let model = DrawingModel(settings: drawingSettings)
                let x = CGFloat.random(in: 100...200)
                let y = CGFloat.random(in: 200...400)
                let figure = Figure.rectangle(
                    RectangleModel(
                        bottomLeft: CGPoint(x: x, y: y),
                        topRight: CGPoint(x: x + 70, y: y - 70),
                        color: Color.random(),
                        lineWidth: CGFloat.random(in: 1...20)
                    )
                )
                model.addFigure(figure: figure)
                model.image = model.getImage(size: drawingViewSize)
                frameModels.append(model)
            }
        }
        editorMode = .normal
        makeLastModelActive()
    }

    func onCopyButtonTapped() {
        generateNewFrameSavingActiveModel()
        let prevIndex = activeModelIndex - 1
        if prevIndex >= 0 {
            activeModel.setFigures(figure: frameModels[prevIndex].allFigures)
        }
    }

    func onGenerateMovingSquareFramesButtonTap(framesNumber: Int) {
        let x = CGFloat.random(in: 100...200)
        let y = CGFloat.random(in: 200...400)
        let width = 70.0
        var rectangleModel = RectangleModel(
            bottomLeft: CGPoint(x: x, y: y),
            topRight: CGPoint(x: x + width, y: y - width),
            color: .black,
            lineWidth: 10
        )

        for _ in 0..<framesNumber {
            autoreleasepool {
                let model = DrawingModel(settings: drawingSettings)
                var randx = CGFloat.random(in: -10...10)
                var randy = CGFloat.random(in: -10...10)
                if rectangleModel.topRight.x + randx > drawingViewSize.width || rectangleModel.bottomLeft.x + x < 0  {
                    randx = -randx
                }
                if rectangleModel.topRight.y + randy < 0 || rectangleModel.bottomLeft.y + randy > drawingViewSize.height  {
                    randy = -randy
                }

                rectangleModel.move(x: randx, y: randy)
                let figure = Figure.rectangle(rectangleModel)
                model.addFigure(figure: figure)
                model.image = model.getImage(size: drawingViewSize)
                frameModels.append(model)
            }
        }
        editorMode = .normal
        makeLastModelActive()
    }

    func removeFrame() {
        _ = frameModels.popLast()
        if frameModels.last == nil { frameModels.append(DrawingModel(settings: drawingSettings) ) }
        makeLastModelActive()
    }

    func removeAllFrames() {
        frameModels = [DrawingModel(settings: drawingSettings)]
        makeLastModelActive()
    }


    func startPlaying() {
        editorMode = .playing
        currentFrameIndex = 0
        invalidateAndStartTimer()
    }

    func stopPlaying() {
        editorMode = .normal
        makeLastModelActive()
        timer?.invalidate()
        timer = nil
    }

    
    var drawingViewMode: DrawingViewMode {
        switch editorMode {
        case .playing: return .playingImage(frameModels[currentFrameIndex].image)
        default: return .showPreviousImage(previousFrameImage)
        }
    }

    var canUndo: Bool { activeModel.canUndo }
    var canRedo: Bool { activeModel.canRedo }
}

private extension AppModel {
    private func nextFrame() {
        currentFrameIndex += 1
        if currentFrameIndex >= frameModels.count {
            currentFrameIndex = 0
        }
    }
    private func makeLastModelActive() { activeModelIndex = frameModels.count - 1 }
    private func setupActiveModelObserver() {
        activeModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    private func invalidateAndStartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(frameRate), repeats: true) { [weak self] _ in
            self?.nextFrame()
        }
    }

    private func generateNewFrameSavingActiveModel() {
        activeModel.image = activeModel.getImage(size: drawingViewSize)
        let model = DrawingModel(settings: drawingSettings)
        frameModels.append(model)
        makeLastModelActive()
    }
}


extension EditorMode {
    var isPlaying: Bool { self == .playing }
}

public extension Color {

    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

//
//  DrawingModel.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation
import SwiftUI

extension DrawingModel {
    func undo() { undoRedoManager.undo() }
    func redo() { undoRedoManager.redo() }
}

protocol DrawingSettings {
    var currentColor: Color { get }
    var lineWidth: CGFloat { get }
    var drawingMode: DrawingMode { get }
}

class DrawingModel: ObservableObject {
    @Published private var currentLine: Line
    @Published private var figures: [Figure] = []

    @Published var image: UIImage?

    var currentColor: Color { drawingSettings.currentColor }

    init(settings: DrawingSettings) {
        self.drawingSettings = settings
        currentLine = Line(points: [], color: settings.currentColor, lineWidth: settings.lineWidth, mode: settings.drawingMode)
    }

    var allFigures: [Figure] { figures + (currentLine.points.count > 0 ? [.line(currentLine)] : []) }

    func addFigure(figure: Figure) {
        figures.append(figure)
    }

    func setFigures(figure: [Figure]) {
        self.figures = figure
    }

    func removeLast() {
        figures.removeLast()
    }

    func addCurrentLine() {
        defer {
            resetCurrentLine()
        }
        guard !attemptToAddErasedLineToEmptyState() else {
            return
        }
        let figure = Figure.line(currentLine)
        figures.append(figure)
        undoRedoManager.append(action: AddFigureAction(model: self, figure: figure))
    }

    func addCurrentLinePoint(newPoint: CGPoint) {
        if currentLine.points.isEmpty {
            currentLine = Line(
                points: [newPoint],
                color: currentColor,
                lineWidth: drawingSettings.lineWidth,
                mode: drawingSettings.drawingMode
            )
        } else {
            currentLine.points.append(newPoint)
        }
    }

    var canUndo: Bool { undoRedoManager.canUndo }
    var canRedo: Bool { undoRedoManager.canRedo }

    private func attemptToAddErasedLineToEmptyState() -> Bool {
        return (figures.isEmpty || figures.allSatisfy({ $0.isErased })) && currentLine.mode == .erase
    }

    private func resetCurrentLine() {
        currentLine = Line(
            points: [],
            color: currentColor,
            lineWidth: drawingSettings.lineWidth,
            mode: drawingSettings.drawingMode
        )
    }

    private let undoRedoManager = UndoRedoManagerImpl()
    private let drawingSettings: DrawingSettings
}

extension Figure {
    var isErased: Bool {
        switch self {
        case .line(let line): return line.mode == .erase
        case .rectangle(_): return false
        }
    }
}

//
//  AddFigureAction.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation

class AddFigureAction: Action {
    init(model: DrawingModel, figure: Figure) {
        self.model = model
        self.figure = figure
    }

    func undo() {
        model.removeLast()
    }

    func redo() {
        model.addFigure(figure: figure)
    }

    private let figure: Figure
    private let model: DrawingModel
}

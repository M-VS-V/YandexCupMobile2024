//
//  UndoRedoManager.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation


protocol UndoRedoManager {
    func undo()
    func redo()
    func append(action: Action)
}

protocol Action {
    func undo()
    func redo()
}

class UndoRedoManagerImpl: ObservableObject {

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func append(action: Action) {
        redoStack = []
        undoStack.append(action)
    }

    func undo() {
        if let action = undoStack.popLast() {
            action.undo()
            redoStack.append(action)
        }
    }

    func redo() {
        if let action = redoStack.popLast() {
            action.redo()
            undoStack.append(action)
        }
    }

    @Published private var redoStack: [Action] = []
    @Published private var undoStack: [Action] = []
}

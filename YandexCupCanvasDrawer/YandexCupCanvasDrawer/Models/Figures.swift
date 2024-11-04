//
//  Figures.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation
import SwiftUI

enum Figure {
    case line(Line)
    case rectangle(RectangleModel)
}

enum DrawingMode {
    case draw
    case erase
}

protocol Moveable {
    mutating func move(x: CGFloat, y: CGFloat)
}

struct RectangleModel: Moveable {
    mutating func move(x: CGFloat, y: CGFloat) {
        bottomLeft = CGPoint(x: bottomLeft.x + x, y: bottomLeft.y + y)
        topRight = CGPoint(x: topRight.x + x, y: topRight.y + y)
    }
    
    var bottomLeft: CGPoint
    var topRight: CGPoint
    var color: Color
    var lineWidth: CGFloat
}

struct Line: Moveable {
    mutating func move(x: CGFloat, y: CGFloat) {
        points = points.map { CGPoint(x: $0.x + x, y: $0.y + y) }
    }
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    var mode: DrawingMode
}

extension Line {
    func getPath() -> Path? {
        guard let firstPoint = points.first else { return nil }
        var path = Path()
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

extension RectangleModel {
    func getPath() -> Path? {
        var path = Path()
        let size = CGSize(width: abs(topRight.x - bottomLeft.x), height: abs(topRight.y - bottomLeft.y))
        path.addRect(CGRect(origin: CGPoint(x: bottomLeft.x, y: topRight.y), size: size))
        return path
    }
}

extension Figure {
    func draw(in context: inout GraphicsContext) {
        switch self {
        case .line(let line):
            guard let path = line.getPath() else { return }
            context.blendMode = line.mode == .erase ? .destinationOut : .normal
            context.stroke(
                path,
                with: .color(line.color),
                style: StrokeStyle(
                    lineWidth: line.lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        case .rectangle(let rectangle):
            guard let path = rectangle.getPath() else { return }
            context.blendMode = .normal
            context.stroke(
                path,
                with: .color(rectangle.color),
                style: StrokeStyle(
                    lineWidth: rectangle.lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}



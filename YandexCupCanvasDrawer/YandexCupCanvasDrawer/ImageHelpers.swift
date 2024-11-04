//
//  ImageHelpers.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import Foundation
import SwiftUI


extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// Функция для преобразования SwiftUI View в UIImage
func convertViewToImage<V: View>(view: V) -> UIImage? {
    let controller = UIHostingController(rootView: view)
    let targetSize = controller.view.intrinsicContentSize
    controller.view.bounds = CGRect(origin: .zero, size: targetSize)
    controller.view.backgroundColor = .clear

    // Отрисовка представления
    let image = controller.view.asImage()

    return image
}


func renderCanvasToImage(canvasView: DrawingView, size: CGSize) -> UIImage {
    let hostingController = UIHostingController(rootView: canvasView)
    hostingController.view.frame = CGRect(origin: .zero, size: size)

    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { _ in
        hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
    }

    return image
}

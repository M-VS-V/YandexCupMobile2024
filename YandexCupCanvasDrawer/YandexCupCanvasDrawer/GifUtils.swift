//
//  GifUtils.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 04.11.2024.
//

import UIKit
import ImageIO

func exportImagesToGIF(images: [UIImage], completion: @escaping (Result<URL, Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.1]]

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("exported.gif")

        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, "com.compuserve.gif" as CFString, images.count, nil) else {
            completion(.failure(NSError(domain: "GIFExportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create GIF destination"])))
            return
        }

        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }

        if CGImageDestinationFinalize(destination) {
            completion(.success(fileURL))
        } else {
            completion(.failure(NSError(domain: "GIFExportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize GIF"])))
        }
    }
}

//
//  ImageGalleryView.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 04.11.2024.
//

import SwiftUI

struct ImageGalleryView: View {
    let appModel: AppModel
    @State var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<images.count, id: \.self) { index in
                    VStack {
                        Text("Кадр \(index + 1)/\(images.count)").foregroundColor(.white).padding()
                        ZStack {
                            Image("wallpaper")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .cornerRadius(10)
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .onTapGesture {
                                    appModel.routeToImage(at: index)
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                        .padding()

                    }
                }
            }
            .padding()
        }
        .navigationTitle("Галерея изображений")
    }
}

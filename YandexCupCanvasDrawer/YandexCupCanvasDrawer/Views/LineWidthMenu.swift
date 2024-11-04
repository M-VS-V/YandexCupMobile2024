//
//  LineWidthView.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import SwiftUI

struct LineWidthMenu: View {
    @Binding var lineWidth: CGFloat
    @Binding var editorMode: EditorMode

    let widthOptions: [CGFloat] = [1, 2, 3, 4, 5, 6, 8, 10]

    var body: some View {
        VStack(spacing: 15) {
            Text("Толщина линии")
                .foregroundColor(.white)
                .font(.headline)

            VStack(spacing: 20) {
                ForEach(widthOptions, id: \.self) { width in
                    Button(action: {
                        lineWidth = width
                        editorMode = .normal
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: width * 2, height: width * 2)

                            Text("\(Int(width)) pt")
                                .foregroundColor(.white)

                            Spacer()

                            if width == lineWidth {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
        .frame(width: 200)
        .background {
            ZStack {
                // Добавляем темный блюр
                Rectangle()
                    .fill(.black.opacity(0.5))

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
            }
        }
        .cornerRadius(15)
        // Добавляем тень для лучшего выделения меню на фоне
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    LineWidthMenu(lineWidth: .constant(10), editorMode: .constant(.isShowingLineWidthMenu))
}

//
//  ToolbarButton.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 03.11.2024.
//

import SwiftUI

struct ToolbarButton: View {
    let systemName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .padding(8)
                .background(isSelected ? Color.white.opacity(0.3) : Color.clear)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ToolbarButton(systemName: "arrow.uturn.backward", isSelected: true, action: {} )
}

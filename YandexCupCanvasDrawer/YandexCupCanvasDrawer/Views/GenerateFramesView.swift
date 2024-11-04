//
//  GenerateFramesView.swift
//  YandexCupCanvasDrawer
//
//  Created by Vsevolod Mashinson on 04.11.2024.
//

import SwiftUI
import Combine

struct GenerateFramesView: View {
    @State private var inputText: String = ""  // Для хранения введенного текста
    @State private var errorMessage: String? = nil  // Для отображения ошибки
    enum Field {
        case framesNumber
    }
    @FocusState private var focusedField: Field?
    var appModel: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Text("Введите количество кадров:")
                    .font(.headline)

                Spacer()
            }
            HStack {
                Spacer()
                TextField("Введите число", text: $inputText)
                    .keyboardType(.numberPad)  // Открывает числовую клавиатуру
                    .onChange(of: inputText) { newValue in
                        validateInput(newValue)
                    }
                    .padding()
                    .background(Color.gray.opacity(1.0))
                    .cornerRadius(8)
                    .focused($focusedField, equals: .framesNumber)
                    .frame(width: 300)
                    .onAppear {
                        self.focusedField = .framesNumber
                    }
                Spacer()
            }

            if let errorMessage = errorMessage {
                HStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                    Spacer()
                }
            }
            HStack {
                Spacer()
                Button(action: { 
                    appModel.onGenerateFramesButtonTap(framesNumber: Int(inputText) ?? 24)
                }) {
                    Text("Сгенерировать случайные квадраты").foregroundColor(.white)
                }
                .padding()
                .background(.blue)
                .cornerRadius(8)
                .opacity(errorMessage != nil ? 0.3 : 1.0)
                .disabled(errorMessage != nil)

                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    appModel.onGenerateMovingSquareFramesButtonTap(framesNumber: Int(inputText) ?? 24)
                }) {
                    Text("Сгенерировать движущийся квадрат").foregroundColor(.white)
                }
                .padding()
                .background(.blue)
                .cornerRadius(8)
                .opacity(errorMessage != nil ? 0.3 : 1.0)
                .disabled(errorMessage != nil)

                Spacer()
            }
        }
        .padding()
    }

    private func validateInput(_ value: String) {
        // Удаляем все нецифровые символы
        let filteredValue = value.filter { $0.isNumber }

        // Присваиваем очищенное значение обратно в inputText
        if filteredValue != value {
            inputText = filteredValue
        }

        // Преобразуем строку в число
        if let number = Int(filteredValue) {
            if number < 1 || number > 1_000_000 {
                errorMessage = "Число должно быть в диапазоне от 1 до 1 000 000"
            } else {
                errorMessage = nil  // Убираем ошибку, если всё нормально
            }
        } else if !filteredValue.isEmpty {
            errorMessage = "Неверный ввод"
        } else {
            errorMessage = nil  // Убираем ошибку, если поле пустое
        }
    }
}

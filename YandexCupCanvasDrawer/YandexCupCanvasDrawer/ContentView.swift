import SwiftUI

enum DrawingViewMode {
    case showPreviousImage(UIImage?)
    case playingImage(UIImage?)
}
struct DrawingView: View {
    @ObservedObject var model: DrawingModel
    let mode: DrawingViewMode // Добавьте это свойство

    var body: some View {
        switch mode {
        case .playingImage(let image):
            if let image {
               Image(uiImage: image)
                   .resizable()
                   .scaledToFit()
                   .opacity(1.0) // Настройте прозрачность по необходимости
            }
        case .showPreviousImage(let image):
            Canvas(opaque: false) { context, size in model.allFigures.forEach { $0.draw(in: &context) } }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ model.addCurrentLinePoint(newPoint: $0.location) })
                    .onEnded({ _ in model.addCurrentLine() })
            )

            if let image {
               Image(uiImage: image)
                   .resizable()
                   .scaledToFit()
                    .opacity(0.3) // Настройте прозрачность по необходимости
            }
        }
    }

    // Полупрозрачное изображение поверх

    func asImage(size: CGSize) -> UIImage {
        let renderer = ImageRenderer(content:
            Canvas(opaque: false) { context, _ in
                model.allFigures.forEach { $0.draw(in: &context) }
            }
            .frame(width: size.width, height: size.height)
        )

        // Если нужна прозрачность
        renderer.isOpaque = false

        return renderer.uiImage ?? UIImage()
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


struct ContentView: View {
    @StateObject private var appModel = AppModel()

    let middleTopButtonSize: CGFloat = 24
    let disabledOpacity: CGFloat = 0.5
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Верхняя панель инструментов
                TopButtons(appModel: appModel)

                // Холст для рисования
                // Контейнер с фоном и холстом для рисования
                 ZStack {
                     // Фоновое изображение
                     Image("wallpaper")
                         .resizable()
                         .scaledToFill()

                     // Холст для рисования
                     DrawingView(model: appModel.activeModel, mode: appModel.drawingViewMode)
                         .background(
                             GeometryReader { geometry in
                                 Color.clear.preference(
                                     key: SizePreferenceKey.self,
                                     value: geometry.size
                                 )
                             }
                         )
                         .onPreferenceChange(SizePreferenceKey.self) { size in
                             appModel.drawingViewSize = size
                         }

                     VStack {
                         Text(appModel.totalFrames)
                             .font(.headline)
                             .italic()
                             .fontWeight(.medium)
                             .foregroundStyle(.black)

                         Spacer()
                     }
                 }
                 .cornerRadius(20)
                 .padding()
                // Нижняя панель инструментов
                HStack(spacing: 30) {
                    ToolbarButton(
                        systemName: "pencil",
                        isSelected: appModel.drawingMode == .draw
                    ) {
                        appModel.drawingMode = .draw
                    }

                    Button(action: { appModel.editorMode = .isShowingLineWidthMenu }) {
                        Image(systemName: "paintbrush")
                            .foregroundColor( appModel.editorMode == .isShowingLineWidthMenu ? .green : .white)
                    }

                    ToolbarButton(
                        systemName: "eraser",
                        isSelected: appModel.drawingMode == .erase
                    ) {
                        appModel.drawingMode = .erase
                    }

                    ColorPicker("", selection: $appModel.currentColor)
                        .labelsHidden()
                }
                .padding()
                .opacity(appModel.isPlaying ? 0.0 : 1.0)
            }

            // Меню выбора толщины линии
            if appModel.editorMode == .isShowingLineWidthMenu {
                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        appModel.editorMode = .normal
                    }

                LineWidthMenu(
                    lineWidth: $appModel.lineWidth,
                    editorMode: $appModel.editorMode
                )
                .transition(.scale)
            }

            if appModel.editorMode == .isShowingFrameGenerationMenu {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        appModel.editorMode = .normal
                    }

                GenerateFramesView(appModel: appModel).transition(.scale)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

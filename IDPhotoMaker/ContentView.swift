import SwiftUI

class AppState: ObservableObject {
    @Published var screen: AppScreen = .home
    @Published var selectedSize: IDPhotoSize? = nil
    @Published var capturedImage: UIImage? = nil
    @Published var processedImage: UIImage? = nil
    @Published var selectedBG: BackgroundColor = .white
    @Published var finalImage: UIImage? = nil
}

struct ContentView: View {
    @StateObject private var state = AppState()

    var body: some View {
        switch state.screen {
        case .home:
            HomeView().environmentObject(state)
        case .sizePicker:
            SizePickerView().environmentObject(state)
        case .capture:
            PhotoCaptureView().environmentObject(state)
        case .processing:
            ProcessingView().environmentObject(state)
        case .editor:
            EditorView().environmentObject(state)
        case .export:
            ExportView().environmentObject(state)
        }
    }
}

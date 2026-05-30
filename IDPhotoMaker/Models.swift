import SwiftUI

struct IDPhotoSize: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let widthMM: Double
    let heightMM: Double
    let icon: String

    var widthPx: Int { Int(widthMM / 25.4 * 300) }
    var heightPx: Int { Int(heightMM / 25.4 * 300) }
    var aspectRatio: Double { widthMM / heightMM }

    static let presets: [IDPhotoSize] = [
        IDPhotoSize(id: "resume", name: "履歴書", subtitle: "40 × 30 mm", widthMM: 30, heightMM: 40, icon: "doc.text.fill"),
        IDPhotoSize(id: "passport", name: "パスポート", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "airplane"),
        IDPhotoSize(id: "mynumber", name: "マイナンバー", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "creditcard.fill"),
        IDPhotoSize(id: "license", name: "免許証更新", subtitle: "24 × 30 mm", widthMM: 24, heightMM: 30, icon: "car.fill"),
        IDPhotoSize(id: "visa_us", name: "米国ビザ", subtitle: "51 × 51 mm", widthMM: 51, heightMM: 51, icon: "globe.americas.fill"),
        IDPhotoSize(id: "student", name: "学生証", subtitle: "30 × 40 mm", widthMM: 30, heightMM: 40, icon: "graduationcap.fill"),
    ]
}

enum BackgroundColor: CaseIterable, Identifiable {
    case white, lightBlue, gray, red

    var id: String { label }

    var label: String {
        switch self {
        case .white: return "白"
        case .lightBlue: return "水色"
        case .gray: return "グレー"
        case .red: return "赤"
        }
    }

    var color: Color {
        switch self {
        case .white: return .white
        case .lightBlue: return Color(red: 0.69, green: 0.87, blue: 1.0)
        case .gray: return Color(red: 0.85, green: 0.85, blue: 0.85)
        case .red: return Color(red: 0.85, green: 0.15, blue: 0.15)
        }
    }
}

enum AppScreen {
    case home
    case sizePicker
    case capture
    case processing
    case editor
    case export
}

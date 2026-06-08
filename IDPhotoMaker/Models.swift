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

    let isPro: Bool

    static let freePresets: [IDPhotoSize] = [
        IDPhotoSize(id: "resume", name: "履歴書", subtitle: "40 × 30 mm", widthMM: 30, heightMM: 40, icon: "doc.text.fill", isPro: false),
        IDPhotoSize(id: "passport", name: "パスポート", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "airplane", isPro: false),
        IDPhotoSize(id: "mynumber", name: "マイナンバー", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "creditcard.fill", isPro: false),
        IDPhotoSize(id: "license", name: "免許証更新", subtitle: "24 × 30 mm", widthMM: 24, heightMM: 30, icon: "car.fill", isPro: false),
        IDPhotoSize(id: "visa_us", name: "米国ビザ", subtitle: "51 × 51 mm", widthMM: 51, heightMM: 51, icon: "globe.americas.fill", isPro: false),
        IDPhotoSize(id: "student", name: "学生証", subtitle: "30 × 40 mm", widthMM: 30, heightMM: 40, icon: "graduationcap.fill", isPro: false),
    ]

    static let proPresets: [IDPhotoSize] = [
        IDPhotoSize(id: "visa_eu", name: "EU/シェンゲンビザ", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "globe.europe.africa.fill", isPro: true),
        IDPhotoSize(id: "visa_cn", name: "中国ビザ", subtitle: "33 × 48 mm", widthMM: 33, heightMM: 48, icon: "globe.asia.australia.fill", isPro: true),
        IDPhotoSize(id: "visa_in", name: "インドビザ", subtitle: "51 × 51 mm", widthMM: 51, heightMM: 51, icon: "globe.asia.australia.fill", isPro: true),
        IDPhotoSize(id: "toeic", name: "TOEIC/英検", subtitle: "30 × 24 mm", widthMM: 24, heightMM: 30, icon: "book.fill", isPro: true),
        IDPhotoSize(id: "securities", name: "証券口座", subtitle: "40 × 30 mm", widthMM: 30, heightMM: 40, icon: "chart.line.uptrend.xyaxis", isPro: true),
        IDPhotoSize(id: "realtor", name: "宅建/資格試験", subtitle: "40 × 30 mm", widthMM: 30, heightMM: 40, icon: "building.columns.fill", isPro: true),
        IDPhotoSize(id: "visa_kr", name: "韓国ビザ", subtitle: "35 × 45 mm", widthMM: 35, heightMM: 45, icon: "globe.asia.australia.fill", isPro: true),
        IDPhotoSize(id: "custom_3x4", name: "3×4cm 汎用", subtitle: "30 × 40 mm", widthMM: 30, heightMM: 40, icon: "square.resize", isPro: true),
        IDPhotoSize(id: "custom_5x5", name: "5×5cm 正方形", subtitle: "50 × 50 mm", widthMM: 50, heightMM: 50, icon: "square.fill", isPro: true),
    ]

    static let presets: [IDPhotoSize] = freePresets + proPresets
}

enum BackgroundColor: CaseIterable, Identifiable {
    case white, lightBlue, gray, red
    case pink, green, navy, beige, lavender, skyBlue

    var id: String { label }
    var isPro: Bool {
        switch self {
        case .white, .lightBlue, .gray, .red: return false
        default: return true
        }
    }

    static var freeColors: [BackgroundColor] { [.white, .lightBlue, .gray, .red] }
    static var proColors: [BackgroundColor] { [.pink, .green, .navy, .beige, .lavender, .skyBlue] }

    var label: String {
        switch self {
        case .white: return "白"
        case .lightBlue: return "水色"
        case .gray: return "グレー"
        case .red: return "赤"
        case .pink: return "ピンク"
        case .green: return "緑"
        case .navy: return "紺"
        case .beige: return "ベージュ"
        case .lavender: return "ラベンダー"
        case .skyBlue: return "空色"
        }
    }

    var color: Color {
        switch self {
        case .white: return .white
        case .lightBlue: return Color(red: 0.69, green: 0.87, blue: 1.0)
        case .gray: return Color(red: 0.85, green: 0.85, blue: 0.85)
        case .red: return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .pink: return Color(red: 1.0, green: 0.82, blue: 0.86)
        case .green: return Color(red: 0.75, green: 0.92, blue: 0.75)
        case .navy: return Color(red: 0.15, green: 0.20, blue: 0.45)
        case .beige: return Color(red: 0.96, green: 0.93, blue: 0.85)
        case .lavender: return Color(red: 0.88, green: 0.83, blue: 0.95)
        case .skyBlue: return Color(red: 0.53, green: 0.81, blue: 0.98)
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

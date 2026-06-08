import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct BeautyFilter: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String

    static let all: [BeautyFilter] = [
        BeautyFilter(id: "natural", name: "ナチュラル美肌", icon: "sparkles"),
        BeautyFilter(id: "smooth", name: "なめらか肌", icon: "drop.fill"),
        BeautyFilter(id: "clear", name: "透明感アップ", icon: "sun.max.fill"),
        BeautyFilter(id: "bright", name: "美白", icon: "moon.fill"),
        BeautyFilter(id: "warm", name: "血色感アップ", icon: "heart.fill"),
        BeautyFilter(id: "dehaze", name: "くすみ除去", icon: "wand.and.stars"),
        BeautyFilter(id: "sharp", name: "シャープ補正", icon: "triangle"),
        BeautyFilter(id: "soft", name: "ソフトフォーカス", icon: "cloud.fill"),
        BeautyFilter(id: "hicontrast", name: "ハイコントラスト", icon: "circle.lefthalf.filled"),
        BeautyFilter(id: "naturalmake", name: "ナチュラルメイク", icon: "paintbrush.fill"),
    ]

    func apply(to image: UIImage) -> UIImage {
        guard let ciInput = CIImage(image: image) else { return image }
        let ctx = CIContext()

        let output: CIImage?
        switch id {
        case "natural":
            output = skinSmooth(ciInput, radius: 3.0, blend: 0.4)
        case "smooth":
            output = skinSmooth(ciInput, radius: 6.0, blend: 0.6)
        case "clear":
            output = adjustColor(ciInput, brightness: 0.04, contrast: 1.05, saturation: 0.92)
        case "bright":
            output = adjustColor(ciInput, brightness: 0.06, contrast: 1.0, saturation: 0.88)
        case "warm":
            output = warmTone(ciInput)
        case "dehaze":
            output = highlightShadow(ciInput, highlight: 0.6, shadow: 0.3)
        case "sharp":
            output = sharpen(ciInput, sharpness: 0.6)
        case "soft":
            output = softFocus(ciInput)
        case "hicontrast":
            output = adjustColor(ciInput, brightness: 0.0, contrast: 1.2, saturation: 1.05)
        case "naturalmake":
            let smoothed = skinSmooth(ciInput, radius: 2.5, blend: 0.3)
            output = adjustColor(smoothed ?? ciInput, brightness: 0.02, contrast: 1.08, saturation: 1.05)
        default:
            output = ciInput
        }

        guard let result = output,
              let cgImage = ctx.createCGImage(result, from: ciInput.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }

    private func skinSmooth(_ input: CIImage, radius: Double, blend: Double) -> CIImage? {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = input
        blur.radius = Float(radius)
        guard let blurred = blur.outputImage else { return nil }

        let blendFilter = CIFilter.sourceOverCompositing()
        let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(1.0 - blend)))
            .cropped(to: input.extent)

        let topLayer = input.applyingFilter("CIBlendWithAlphaMask", parameters: [
            kCIInputMaskImageKey: mask
        ])

        let composite = blurred.applyingFilter("CIBlendWithAlphaMask", parameters: [
            kCIInputBackgroundImageKey: topLayer,
            kCIInputMaskImageKey: CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(blend))).cropped(to: input.extent)
        ])

        // Simple approach: blend blurred with original
        let blendAmount = CIFilter(name: "CIDissolveTransition")
        blendAmount?.setValue(input, forKey: kCIInputImageKey)
        blendAmount?.setValue(blurred.cropped(to: input.extent), forKey: kCIInputTargetImageKey)
        blendAmount?.setValue(NSNumber(value: blend), forKey: kCIInputTimeKey)
        return blendAmount?.outputImage ?? composite
    }

    private func adjustColor(_ input: CIImage, brightness: Double, contrast: Double, saturation: Double) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = input
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)
        return filter.outputImage
    }

    private func warmTone(_ input: CIImage) -> CIImage? {
        let temp = CIFilter.temperatureAndTint()
        temp.inputImage = input
        temp.neutral = CIVector(x: 6800, y: 0)
        temp.targetNeutral = CIVector(x: 5500, y: 0)
        guard let warmed = temp.outputImage else { return nil }
        return adjustColor(warmed, brightness: 0.01, contrast: 1.02, saturation: 1.08)
    }

    private func highlightShadow(_ input: CIImage, highlight: Double, shadow: Double) -> CIImage? {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = input
        filter.highlightAmount = Float(highlight)
        filter.shadowAmount = Float(shadow)
        return filter.outputImage
    }

    private func sharpen(_ input: CIImage, sharpness: Double) -> CIImage? {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = input
        filter.sharpness = Float(sharpness)
        return filter.outputImage
    }

    private func softFocus(_ input: CIImage) -> CIImage? {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = input
        blur.radius = 2.0
        guard let blurred = blur.outputImage?.cropped(to: input.extent) else { return nil }
        let blend = CIFilter(name: "CIDissolveTransition")
        blend?.setValue(input, forKey: kCIInputImageKey)
        blend?.setValue(blurred, forKey: kCIInputTargetImageKey)
        blend?.setValue(NSNumber(value: 0.35), forKey: kCIInputTimeKey)
        return blend?.outputImage
    }
}

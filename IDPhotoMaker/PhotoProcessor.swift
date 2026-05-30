import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

enum ProcessingError: LocalizedError {
    case invalidImage, noResult, processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "画像の読み込みに失敗しました"
        case .noResult: return "人物を検出できませんでした"
        case .processingFailed: return "背景除去に失敗しました"
        }
    }
}

actor PhotoProcessor {
    static func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else { throw ProcessingError.invalidImage }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let result = request.results?.first else { throw ProcessingError.noResult }

        let maskPixelBuffer = try result.generateScaledMaskForImage(
            forInstances: result.allInstances,
            from: handler
        )

        let originalCI = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cvPixelBuffer: maskPixelBuffer)

        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = originalCI
        blendFilter.maskImage = maskCI
        blendFilter.backgroundImage = CIImage.empty()

        guard let outputCI = blendFilter.outputImage else { throw ProcessingError.processingFailed }

        let context = CIContext()
        guard let outputCG = context.createCGImage(outputCI, from: originalCI.extent) else {
            throw ProcessingError.processingFailed
        }

        return UIImage(cgImage: outputCG)
    }

    static func compositeOnBackground(
        foreground: UIImage,
        background: UIColor,
        targetSize: IDPhotoSize
    ) -> UIImage {
        let px = CGSize(width: targetSize.widthPx, height: targetSize.heightPx)
        let renderer = UIGraphicsImageRenderer(size: px)
        return renderer.image { ctx in
            background.setFill()
            ctx.fill(CGRect(origin: .zero, size: px))

            // Scale foreground to fill, centered
            guard let fg = foreground.cgImage else { return }
            let fgSize = CGSize(width: fg.width, height: fg.height)
            let scale = max(px.width / fgSize.width, px.height / fgSize.height)
            let scaledW = fgSize.width * scale
            let scaledH = fgSize.height * scale
            let x = (px.width - scaledW) / 2
            let y = (px.height - scaledH) / 2
            foreground.draw(in: CGRect(x: x, y: y, width: scaledW, height: scaledH))
        }
    }
}

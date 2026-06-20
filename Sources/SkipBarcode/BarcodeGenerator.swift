// SPDX-License-Identifier: MIT
#if os(iOS)
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// 2D / 1D barcode **image** generation using iOS system APIs (Core Image).
///
/// Available on iOS only — Android has no system barcode *generator*. For a
/// cross-platform 1D option, use ``Code128/encode(_:)`` and draw the bars
/// yourself (see the README), which works on both platforms.
public enum BarcodeImageFormat: String, Sendable, CaseIterable {
    case qr, aztec, pdf417, code128
}

public enum BarcodeGenerator {
    /// Generates a barcode as a `CGImage` (crisp, unscaled — scale it with
    /// `.interpolation(.none)` when displaying).
    public static func cgImage(_ string: String, format: BarcodeImageFormat) -> CGImage? {
        let data = Data(string.utf8)
        var output: CIImage?
        switch format {
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = data
            filter.correctionLevel = "M"
            output = filter.outputImage
        case .aztec:
            let filter = CIFilter.aztecCodeGenerator()
            filter.message = data
            output = filter.outputImage
        case .pdf417:
            let filter = CIFilter.pdf417BarcodeGenerator()
            filter.message = data
            output = filter.outputImage
        case .code128:
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = data
            output = filter.outputImage
        }
        guard let output else { return nil }
        return CIContext().createCGImage(output, from: output.extent)
    }

    /// Generates a barcode as a SwiftUI `Image` with nearest-neighbour scaling.
    public static func image(_ string: String, format: BarcodeImageFormat) -> Image? {
        guard let cg = cgImage(string, format: format) else { return nil }
        return Image(decorative: cg, scale: 1).interpolation(.none)
    }
}
#endif

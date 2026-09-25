// SPDX-License-Identifier: Apache-2.0
#if os(iOS)
import AVFoundation

/// Symbologies that the camera scanner can recognise. Maps to the platform's
/// metadata types. (Android's ML Kit scans all supported formats by default.)
public enum BarcodeFormat: String, Sendable, CaseIterable {
    // 1D
    case code128, code39, code93, ean13, ean8, upce, itf
    // 2D
    case qr, pdf417, aztec, dataMatrix

    var avMetadataType: AVMetadataObject.ObjectType? {
        switch self {
        case .code128: return .code128
        case .code39: return .code39
        case .code93: return .code93
        case .ean13: return .ean13
        case .ean8: return .ean8
        case .upce: return .upce
        case .itf: return .itf14
        case .qr: return .qr
        case .pdf417: return .pdf417
        case .aztec: return .aztec
        case .dataMatrix: return .dataMatrix
        }
    }

    /// Maps a list of formats to AVFoundation metadata object types.
    public static func avTypes(_ formats: [BarcodeFormat]) -> [AVMetadataObject.ObjectType] {
        formats.compactMap { $0.avMetadataType }
    }
}
#endif

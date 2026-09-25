// SPDX-License-Identifier: Apache-2.0
#if !SKIP_BRIDGE
import Foundation

/// Marker type for the SkipBarcode module.
///
/// SkipBarcode provides cross-platform 1D/2D barcode **generation** (`Code128`)
/// and camera **scanning** (`BarcodeScannerView` on iOS, `AndroidBarcodeScanner`
/// on Android) for Skip apps.
public enum SkipBarcode {
    public static let version = "0.1.0"
}
#endif

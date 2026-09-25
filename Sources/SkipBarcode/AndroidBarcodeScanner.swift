// SPDX-License-Identifier: Apache-2.0
import Foundation

#if !SKIP_BRIDGE
/// Launches the full-screen CameraX + ML Kit barcode scanner on Android.
///
/// On iOS use ``BarcodeScannerView`` instead. Typical cross-platform usage:
///
/// ```swift
/// #if os(Android)
/// Color.clear.onAppear {
///     AndroidBarcodeScanner.scan { code in /* … */ }
/// }
/// #else
/// BarcodeScannerView { code in /* … */ }
/// #endif
/// ```
public struct AndroidBarcodeScanner {

    /// Launches the scanner. `completion` is called once with the scanned value,
    /// or `nil` if the user cancelled or scanning failed.
    public static func scan(completion: @escaping @Sendable (String?) -> Void) {
        #if SKIP
        let ctx = ProcessInfo.processInfo.androidContext
        skip.barcode.ScanHostActivity.clearResult()
        skip.barcode.ScanHostActivity.launch(ctx)

        Task.detached {
            // Poll the static result slot for up to ~60s.
            for _ in 0..<600 {
                if skip.barcode.ScanHostActivity.hasResult() {
                    let resultCode = skip.barcode.ScanHostActivity.getResultCode()
                    let barcode = skip.barcode.ScanHostActivity.getBarcode()
                    skip.barcode.ScanHostActivity.clearResult()
                    completion(resultCode == android.app.Activity.RESULT_OK ? barcode : nil)
                    return
                }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            completion(nil)
        }
        #else
        completion(nil)
        #endif
    }
}
#endif

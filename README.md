# SkipBarcode

Cross-platform **barcode generation and scanning** for [Skip](https://skip.tools)
apps — one Swift API, native on both iOS and Android.

- **Generate** Code 128 barcodes with a dependency-free, pure-Swift encoder you
  can render with any drawing primitive (SwiftUI `Canvas`, `Path`, a bitmap…).
- **Scan** barcodes with the device camera:
  - **iOS** — `AVCaptureMetadataOutput` via the SwiftUI `BarcodeScannerView`.
  - **Android** — CameraX + Google ML Kit via a bundled native scanner activity.

Modelled on the structure of [skip-qrcode](https://github.com/skiptools/skip-qrcode),
packaged as a reusable, bridgeable Skip module (`mode: transpiled`, `bridging: true`)
so it can be consumed from Skip Fuse (native Swift) apps.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/<you>/skip-barcode.git", from: "0.1.0")
```

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "SkipBarcode", package: "skip-barcode")
])
```

The package merges the required `CAMERA` permission and scanner activities into
your Android manifest automatically. On iOS, add an
`NSCameraUsageDescription` entry to your `Info.plist`.

## Generating a Code 128 barcode

`Code128.encode` returns a module pattern (`[Bool]`, `true` = black bar). Render
it however you like. Note that SwiftUI `Canvas` is **not** available in
SkipUI/Compose, so on Skip draw the bars with basic layout primitives — an
`HStack` of rectangles renders identically on iOS and Android:

```swift
import SwiftUI
import SkipBarcode

struct BarcodeView: View {
    let value: String
    var body: some View {
        let bars = Code128.encode(value) ?? []
        GeometryReader { geo in
            let module = bars.isEmpty ? 0 : geo.size.width / CGFloat(bars.count)
            HStack(spacing: 0) {
                ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                    Rectangle()
                        .fill(bar ? Color.black : Color.white)
                        .frame(width: module)
                }
            }
        }
        .background(.white)
    }
}
```

> Tip: merge consecutive equal modules into wider rectangles to cut the view
> count (a typical Code 128 has ~150 modules but far fewer runs).

## Scanning

`BarcodeScannerView` (iOS) and `AndroidBarcodeScanner` (Android) share the same
callback shape, so a small `#if os(Android)` split is all you need:

```swift
import SwiftUI
import SkipBarcode

struct ScannerSheet: View {
    var onScan: (String) -> Void
    var body: some View {
        #if os(Android)
        Color.clear.onAppear {
            AndroidBarcodeScanner.scan { code in
                if let code { onScan(code) }
            }
        }
        #else
        BarcodeScannerView { code in onScan(code) }
            .ignoresSafeArea()
        #endif
    }
}
```

## Generating with system APIs (iOS)

On iOS, `BarcodeGenerator` produces images for several formats via Core Image:

```swift
import SkipBarcode
// QR, Aztec, PDF417, Code 128 → SwiftUI Image
let image = BarcodeGenerator.image("https://thw.de", format: .qr)
```

Android has no system barcode *generator*, so for a cross-platform 1D option use
`Code128.encode` + your own drawing (above). 2D generation on Android would
require a third-party library (e.g. ZXing) and is out of scope here.

## Choosing scan formats

`BarcodeScannerView(formats:)` restricts recognised symbologies on iOS (e.g.
`[.code128]` for an ID card to avoid misreads). Android's ML Kit scans all
supported formats by default.

```swift
BarcodeScannerView(formats: [.code128, .qr]) { code in /* … */ }
```

## Supported symbologies

- **Scanning:** `code128, code39, code93, ean13, ean8, upce, itf, qr, pdf417,
  aztec, dataMatrix` (iOS, via `BarcodeFormat`); all ML Kit formats incl.
  Codabar/UPC-A (Android).
- **Generation:** Code 128 (cross-platform, pure Swift) + QR / Aztec / PDF417 /
  Code 128 images (iOS, Core Image).

## Requirements

- iOS 17+, Android (via Skip)
- Swift 6, Skip 1.6+

## License

MIT — see [LICENSE.txt](LICENSE.txt).

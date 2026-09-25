// swift-tools-version: 6.0
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "skip-barcode",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SkipBarcode", targets: ["SkipBarcode"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", from: "1.6.27"),
        .package(url: "https://github.com/skiptools/skip-foundation.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SkipBarcode", dependencies: [
            .product(name: "SkipFoundation", package: "skip-foundation"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipBarcodeTests", dependencies: [
            "SkipBarcode",
            .product(name: "SkipTest", package: "skip"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

// When bridged into a native (Skip Fuse) app, pull in SkipFuseUI so the
// SwiftUI scanner view is available to native consumers.
if Context.environment["SKIP_BRIDGE"] ?? "0" != "0" {
    package.dependencies += [.package(url: "https://github.com/skiptools/skip-fuse-ui.git", from: "1.0.0")]
    package.targets.forEach { target in
        target.dependencies += [.product(name: "SkipFuseUI", package: "skip-fuse-ui")]
    }
}

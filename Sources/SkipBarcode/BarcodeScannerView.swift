// SPDX-License-Identifier: MIT
#if os(iOS)
import SwiftUI
import AVFoundation
import UIKit

/// A SwiftUI live-camera barcode scanner for iOS, backed by `AVCaptureMetadataOutput`.
///
/// Supports the common 1D/2D symbologies (Code 128, QR, EAN, PDF417, Data Matrix, …).
/// The host app must declare `NSCameraUsageDescription` in its Info.plist.
///
/// On Android use ``AndroidBarcodeScanner/scan(completion:)`` instead.
public struct BarcodeScannerView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = ScannerViewController

    private let formats: [BarcodeFormat]
    private let onScan: (String) -> Void
    private let onError: ((Error) -> Void)?

    /// - Parameters:
    ///   - formats: Symbologies to recognise. Defaults to all supported formats.
    ///   - onError: Called if the camera/session can't be configured.
    ///   - onScan: Called with the decoded string on the first detection.
    public init(formats: [BarcodeFormat] = BarcodeFormat.allCases,
                onError: ((Error) -> Void)? = nil,
                onScan: @escaping (String) -> Void) {
        self.formats = formats
        self.onScan = onScan
        self.onError = onError
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.symbologies = BarcodeFormat.avTypes(formats)
        vc.onScan = onScan
        vc.onError = onError
        return vc
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

/// The `UIViewController` that owns the capture session for ``BarcodeScannerView``.
public final class ScannerViewController: UIViewController, @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    var symbologies: [AVMetadataObject.ObjectType] = [
        .code128, .qr, .ean13, .ean8, .code39, .code93, .pdf417, .dataMatrix, .upce, .aztec,
    ]
    var onScan: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "skip.barcode.session")
    private var didScan = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didScan = false
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            onError?(NSError(domain: "skip.barcode", code: 1,
                             userInfo: [NSLocalizedDescriptionKey: "Camera unavailable"]))
            return
        }
        session.beginConfiguration()
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            onError?(NSError(domain: "skip.barcode", code: 2,
                             userInfo: [NSLocalizedDescriptionKey: "Cannot add metadata output"]))
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        // Intersect requested types with what the device actually supports.
        let supported = Set(output.availableMetadataObjectTypes)
        output.metadataObjectTypes = symbologies.filter { supported.contains($0) }
        session.commitConfiguration()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        guard !didScan,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue else { return }
        didScan = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onScan?(value)
    }
}
#endif

import Flutter
import UIKit
import CoreImage

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    private let documentProcessor = DocumentProcessor()
    private let ciContext = CIContext(options: nil)

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupMethodChannel(with: engineBridge.applicationRegistrar.messenger())
    }

    private func setupMethodChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.vladsava.ml_test/document_processing",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            if call.method == "processDocument" {
                guard let args = call.arguments as? [String: Any],
                      let imagePath = args["imagePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Image path required", details: nil))
                    return
                }
                let guidePoints = args["points"] as? [[String: Double]]
                self.processDocument(imagePath: imagePath, guidePoints: guidePoints, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func processDocument(
        imagePath: String,
        guidePoints: [[String: Double]]?,
        result: @escaping FlutterResult
    ) {
        documentProcessor.process(imagePath: imagePath, guidePoints: guidePoints) { [weak self] (outcome: Result<CIImage, ProcessingError>) in
            guard let self else { return }
            switch outcome {
            case .success(let enhancedImage):
                guard let cgImage = self.ciContext.createCGImage(enhancedImage, from: enhancedImage.extent) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "RENDER_ERROR", message: "Failed to render CIImage", details: nil))
                    }
                    return
                }
                
                let uiImage = UIImage(cgImage: cgImage)
                guard let jpegData = uiImage.jpegData(compressionQuality: 0.9) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "JPEG_ERROR", message: "Failed to create JPEG data", details: nil))
                    }
                    return
                }
                
                DispatchQueue.main.async { 
                    result(FlutterStandardTypedData(bytes: jpegData)) 
                }
            case .failure(let error):
                let message: String
                switch error {
                case .loadFailed(let msg), .processingFailed(let msg):
                    message = msg
                }
                DispatchQueue.main.async {
                    result(FlutterError(code: "LOAD_ERROR", message: message, details: nil))
                }
            }
        }
    }
}

import UIKit
import Vision
import CoreImage

enum ProcessingError: Error {
    case loadFailed(String)
    case processingFailed(String)
}

class DocumentProcessor {

    func process(
        imagePath: String,
        guidePoints: [[String: Double]]?,
        completion: @escaping (Result<CIImage, ProcessingError>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let inputImage = CIImage(contentsOf: URL(fileURLWithPath: imagePath)) else {
                completion(.failure(.loadFailed("Failed to load image")))
                return
            }

            if let gps = guidePoints, gps.count >= 4 {
                let height = inputImage.extent.height
                let ciPoints = gps.map { CGPoint(x: $0["x"] ?? 0, y: height - ($0["y"] ?? 0)) }

                let corrected = inputImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                    "inputTopLeft":     CIVector(cgPoint: ciPoints[0]),
                    "inputTopRight":    CIVector(cgPoint: ciPoints[1]),
                    "inputBottomRight": CIVector(cgPoint: ciPoints[2]),
                    "inputBottomLeft":  CIVector(cgPoint: ciPoints[3])
                ])
                completion(.success(self.enhance(corrected)))
                return
            }

            let handler = VNImageRequestHandler(ciImage: inputImage, options: [:])
            let request = VNDetectRectanglesRequest { req, err in
                if let err = err {
                    print("DocumentProcessor Vision error: \(err)")
                    completion(.success(self.enhance(inputImage)))
                    return
                }

                guard let rect = (req.results as? [VNRectangleObservation])?.first else {
                    completion(.success(self.enhance(inputImage)))
                    return
                }

                let corrected = inputImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                    "inputTopLeft":     CIVector(cgPoint: self.mapPoint(rect.topLeft,     to: inputImage.extent)),
                    "inputTopRight":    CIVector(cgPoint: self.mapPoint(rect.topRight,    to: inputImage.extent)),
                    "inputBottomRight": CIVector(cgPoint: self.mapPoint(rect.bottomRight, to: inputImage.extent)),
                    "inputBottomLeft":  CIVector(cgPoint: self.mapPoint(rect.bottomLeft,  to: inputImage.extent))
                ])
                completion(.success(self.enhance(corrected)))
            }

            request.minimumConfidence = 0.8
            request.maximumObservations = 1

            do {
                try handler.perform([request])
            } catch {
                print("DocumentProcessor Vision handler error: \(error)")
                completion(.success(self.enhance(inputImage)))
            }
        }
    }

    private func enhance(_ image: CIImage) -> CIImage {
        return image.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey:   1.1,
            kCIInputSaturationKey: 1.1
        ])
    }

    private func mapPoint(_ point: CGPoint, to extent: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x * extent.width  + extent.origin.x,
            y: point.y * extent.height + extent.origin.y
        )
    }
}

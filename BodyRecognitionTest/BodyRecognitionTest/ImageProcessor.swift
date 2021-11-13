//
//  Body.swift
//  ImageProcessor
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import UIKit
import Vision

protocol ImageProcessing: AnyObject {
  func update(image: UIImage)
}

class ImageProcessingImpl: ImageProcessing {
  private let imageContainer: UIImageView

  init(imageContainer: UIImageView) {
    self.imageContainer = imageContainer
  }

  func update(image: UIImage) {
    imageContainer.image = image
  }
}

final class ImageProcessor {
  private struct ImageInfo {
    let cgImage: CGImage
    let size: CGSize

    init(cgImage: CGImage) {
      self.cgImage = cgImage
      self.size = CGSize(width: cgImage.width, height: cgImage.height)
    }
  }

  weak var delegate: ImageProcessing?
  private var imageInfo: ImageInfo?

  func getImageWithPoints(cgImage: CGImage?) {
    imageInfo = cgImage.map(ImageInfo.init)

    guard let cgImage = imageInfo?.cgImage else {
      return
    }

    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let bodyPoseRequest = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
    try? requestHandler.perform(bodyPoseRequest)
  }

  private func bodyPoseHandler(request: VNRequest, error: Error?) {
    guard let cgImage = imageInfo?.cgImage,
      let observations = request.results as? [VNHumanBodyPoseObservation],
      !observations.isEmpty else {
      return
    }

    let flatten = observations.map(processObservation)
      .compactMap { $0 }.flatMap { $0 }

    guard let image = cgImage.drawPoints(points: flatten)?.asUIImage else {
      return
    }

    onMainThreadAsync {
      self.delegate?.update(image: image)
    }
  }

  private func processObservation(
    _ observation: VNHumanBodyPoseObservation
  ) -> [CGPoint]? {
    guard let recognizedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
      return []
    }

    recognizedPoints.keys.forEach { key in
      print(key, key.rawValue)
    }

    return recognizedPoints.values.compactMap {
      guard $0.confidence > 0, let size = imageInfo?.size else {
        return nil
      }

      return VNImagePointForNormalizedPoint(
        $0.location,
        Int(size.width),
        Int(size.height)
      )
    }
  }
}

extension VNImageRequestHandler {
  func perform(_ request: VNRequest) throws {
    try perform([request])
  }
}

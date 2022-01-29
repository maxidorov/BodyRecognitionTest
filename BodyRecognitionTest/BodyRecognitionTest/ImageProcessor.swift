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
  func didSquat()
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
  private var squatsCounter = SquatsCounter()
  
  init() {
    self.squatsCounter.delegate = self
  }

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
    guard let observations = request.results as? [VNHumanBodyPoseObservation], !observations.isEmpty else {
      imageInfo.map { imageInfo in
        onMainThreadAsync {
          self.delegate?.update(image: imageInfo.cgImage.asUIImage)
        }
      }
      return
    }

    guard let cgImage = imageInfo?.cgImage,
        let points = processObservation(observations[0]),
        let image = cgImage.drawSkeleton(points: points)?.asUIImage else {
      return
    }
    
    squatsCounter.processPose(skeleton: points)
    
    onMainThreadAsync {
      self.delegate?.update(image: image)
    }
  }

  private func processObservation(
    _ observation: VNHumanBodyPoseObservation
  ) -> [JointName: CGPoint?]? {
    let jointNames = observation.availableJointNames
    let points = jointNames.map { (jointName: JointName) -> CGPoint? in
      guard let recognizedPoint = try? observation.recognizedPoint(jointName),
            recognizedPoint.confidence > 0,
            let size = imageInfo?.size else {
        return nil
      }

      return VNImagePointForNormalizedPoint(
        recognizedPoint.location,
        Int(size.width),
        Int(size.height)
      )
    }

    var dict: [JointName: CGPoint?] = [:]
    for (i, jointName) in jointNames.enumerated() {
      dict[jointName] = points[i]
    }

    return dict
  }
}

extension VNImageRequestHandler {
  func perform(_ request: VNRequest) throws {
    try perform([request])
  }
}

extension ImageProcessor: SquatsCounterDelegate {
  func didSquat() {
    self.delegate?.didSquat()
  }
}

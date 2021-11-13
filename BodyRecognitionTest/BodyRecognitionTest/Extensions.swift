//
//  Extensions.swift
//  BodyRecognitionTest
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import UIKit
import CoreGraphics
import Vision

func onMainThreadAsync(_ block: @escaping () -> Void) {
  if Thread.isMainThread {
    block()
  } else {
    DispatchQueue.main.async {
      block()
    }
  }
}

extension CGImage {
  var asUIImage: UIImage {
    UIImage(cgImage: self)
  }

  func drawPoints(points: [CGPoint]) -> CGImage? {
    guard let ctx = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace ?? CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      return nil
    }

    let selfSize = CGSize(width: width, height: height)
    let selfRect = CGRect(origin: .zero, size: selfSize)
    ctx.draw(self, in: selfRect)

    let fillColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    ctx.setFillColor(fillColor)
    
    for point in points {
      ctx.addArc(center: point)
      ctx.drawPath(using: .fill)
    }

    return ctx.makeImage()
  }
}

fileprivate extension CGContext {
  func addArc(center: CGPoint) {
    addArc(
      center: center,
      radius: 3,
      startAngle: 0,
      endAngle: CGFloat(2 * Double.pi),
      clockwise: false
    )
  }
}

fileprivate typealias JointName = VNHumanBodyPoseObservation.JointName
fileprivate let jointsGraph: [[JointName]] = [
  [.nose, .leftEar],
  [.nose, .rightEar],
  [.nose, .leftEye],
  [.nose, .rightEye],
  [.nose, .neck],
  [.neck, .leftShoulder],
  [.leftShoulder, .leftElbow],
  [.leftElbow, .leftWrist],
  [.neck, .rightShoulder],
  [.rightShoulder, .rightElbow],
  [.rightElbow, .rightWrist],
  [.leftShoulder, .leftHip],
  [.neck, .root],
  [.rightShoulder, .rightHip],
  [.leftHip, .leftKnee],
  [.leftKnee, .leftAnkle],
  [.rightHip, .rightKnee],
  [.rightKnee, .rightAnkle]
]

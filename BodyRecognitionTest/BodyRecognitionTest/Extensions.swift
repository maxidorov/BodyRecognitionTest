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

  func drawSkeleton(points: [JointName : CGPoint?]) -> CGImage? {
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


//    print(points.sorted { $0.key < $1.key }.map(\.key.rawValue.rawValue).map { ["\($0)_x", "\($0)_y"]}.flatMap { $0 })
//    print(points.sorted { $0.key < $1.key }.map { $0.value ?? .zero })
    print(points.sorted { $0.key < $1.key }.map(\.value).map { point in
      point.map {
        ["\($0.x)", "\($0.y)"]
      } ?? ["nil", "nil"]
    }.flatMap { $0 }.toPrint)
  
    let selfSize = CGSize(width: width, height: height)
    let selfRect = CGRect(origin: .zero, size: selfSize)
    ctx.draw(self, in: selfRect)

    let fillColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    ctx.setFillColor(fillColor)

    for point in points {
      guard let cgPoint = point.value else { continue }
      let jointName = point.key

      ctx.addArc(center: cgPoint)
      ctx.drawPath(using: .fill)

      for edge in jointsGraph {
        if edge[0] == jointName {
          let startPoint = cgPoint
          if let finishPoint = points[edge[1]], let finishPoint = finishPoint {
            ctx.drawLine(startPoint: startPoint, finishPoint: finishPoint, lineWidth:3, color: fillColor)
          }
        }
      }
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

fileprivate extension CGContext {
  func drawLine(startPoint: CGPoint, finishPoint: CGPoint, lineWidth: CGFloat, color: CGColor ) {
    setStrokeColor(color)
    setLineWidth(lineWidth)
    move(to: startPoint)
    addLine(to: finishPoint)
    drawPath(using: .fillStroke)
  }
}

extension VNHumanBodyPoseObservation.JointName: Comparable {
  public static func < (lhs: VNHumanBodyPoseObservation.JointName, rhs: VNHumanBodyPoseObservation.JointName) -> Bool {
    return lhs.rawValue.rawValue < rhs.rawValue.rawValue
  }
}

typealias JointName = VNHumanBodyPoseObservation.JointName
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
  [.root, .leftHip],
  [.root, .rightHip],
  [.rightShoulder, .rightHip],
  [.leftHip, .leftKnee],
  [.leftKnee, .leftAnkle],
  [.rightHip, .rightKnee],
  [.rightKnee, .rightAnkle]
]

extension Array {
    var toPrint: String  {
        var str = ""
        for element in self {
            str += "\(element) "
        }
        return str
    }
}


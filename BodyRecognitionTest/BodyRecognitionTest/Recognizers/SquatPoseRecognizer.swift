//
//  PoseRecognizer.swift
//  BodyRecognitionTest
//
//  Created by Dmitrii Zhbannikov on 27.01.2022.
//

import UIKit

import Foundation
import CoreML

final class SquatPoseRecognizer {
  
  enum Pose: String {
    case seat = "seat"
    case stand = "stand"
    case initial = "initial"
  }
  
  func convertToMlData(skeleton: [JointName: CGPoint?]?) -> [Double]? {
    
    var dataSkeleton: [Double] = []
    
    guard let skeleton = skeleton, let root = skeleton[.root], let XRoot = root?.x, let YRoot = root?.y else {
      return nil
    }
    
    let sortedSkeleton = skeleton.sorted { $0.key < $1.key }.map(\.value)
    
    for point in sortedSkeleton {
      if let point = point {
        dataSkeleton.append(Double(point.x) - XRoot)
        dataSkeleton.append(Double(point.y) - YRoot)
      } else {
        return nil
      }
    }
    
    return dataSkeleton
    
  }
  
  func recognize(skeleton: [JointName: CGPoint?]?) -> Pose? {
    
    guard let dataSkeleton = convertToMlData(skeleton: skeleton) else {
      return nil
    }
    
    do {
      
      let model = try SquatPoseRecognizerModel(configuration: MLModelConfiguration())
      
      let input = SquatPoseRecognizerModelInput(x_nose: dataSkeleton[0], y_nose: dataSkeleton[1], x_leftEar: dataSkeleton[2], y_leftEar: dataSkeleton[3], x_leftEye: dataSkeleton[4], y_leftEye: dataSkeleton[5], x_leftAnkle: dataSkeleton[6], y_leftAnkle: dataSkeleton[7], x_leftElbow: dataSkeleton[8], y_leftElbow: dataSkeleton[9], x_leftWrist: dataSkeleton[10], y_leftWrist: dataSkeleton[11], x_leftKnee: dataSkeleton[12], y_leftKnee: dataSkeleton[13], x_leftShoulder: dataSkeleton[14], y_leftShoulder: dataSkeleton[15], x_leftHip: dataSkeleton[16], y_leftHip: dataSkeleton[17], x_neck: dataSkeleton[18], y_neck: dataSkeleton[19], x_rightEar: dataSkeleton[20], y_rightEar: dataSkeleton[21], x_rightEye: dataSkeleton[22], y_rightEye: dataSkeleton[23], x_rightAnkle: dataSkeleton[24], y_rightAnkle: dataSkeleton[25], x_rightElbow: dataSkeleton[26], y_rightElbow: dataSkeleton[27], x_rightWrist: dataSkeleton[28], y_rightWrist: dataSkeleton[29], x_rightKnee: dataSkeleton[30], y_rightKnee: dataSkeleton[31], x_rightShoulder: dataSkeleton[32], y_rightShoulder: dataSkeleton[33], x_rightHip: dataSkeleton[34], y_rightHip: dataSkeleton[35], x_root: dataSkeleton[36], y_root: dataSkeleton[37])
      let output = try model.prediction(input: input)
      print(output.poseClass)
      return Pose(rawValue: output.poseClass)
      
    } catch {
      return nil
    }
    
  }
  
}

//
//  SquatsCounter.swift
//  BodyRecognitionTest
//
//  Created by Dmitrii Zhbannikov on 29.01.2022.
//

import Foundation
import UIKit

protocol SquatsCounterDelegate {
  func didSquat()
}

final class SquatsCounter {
  
  private var squatPoseRecognizer = SquatPoseRecognizer()
  
  private var poseCounter = 0
  private var state: SquatPoseRecognizer.Pose = .initial
  private var lastState: SquatPoseRecognizer.Pose = .initial
  
  var delegate: SquatsCounterDelegate?
  
  func processPose(skeleton: [JointName: CGPoint?]?) {
    
    if let pose = squatPoseRecognizer.recognize(skeleton: skeleton) {
      
      if state == .initial {
        state = pose
      }
      if state == pose {
        poseCounter += 1
      } else {
        lastState = state
        state = pose
        if poseCounter >= 5 {
          if state == .stand && lastState == .seat {
            delegate?.didSquat()
          }
          poseCounter = 0
        }
      }
      
    }
  
  }
  
}

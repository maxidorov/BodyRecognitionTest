//
//  ProcessedImageViewWithCounter.swift
//  BodyRecognitionTest
//
//  Created by Dmitrii Zhbannikov on 27.01.2022.
//

import Foundation
import UIKit

final class ProcessedImageViewWithCounter: UIImageView {
  
  var squatsСounterView: UILabel
  var squatsCount: Int = 0  {
    didSet {
      squatsСounterView.text = String(squatsCount)
    }
}
  
  init() {
    squatsСounterView = UILabel()
    squatsСounterView.font = UIFont.systemFont(ofSize: 60.0)
    squatsСounterView.textColor = .green
    squatsСounterView.text = "0"
    squatsСounterView.translatesAutoresizingMaskIntoConstraints = false
    
    super.init(image: nil, highlightedImage: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

//
//  CameraFeedView.swift
//  BodyRecognitionTest
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import UIKit
import AVFoundation

class CameraFeedView: UIView {
  private var previewLayer: AVCaptureVideoPreviewLayer!

  init(
    frame: CGRect = .zero,
    session: AVCaptureSession,
    videoOrientation: AVCaptureVideoOrientation
  ) {
    super.init(frame: frame)
    previewLayer = layer as? AVCaptureVideoPreviewLayer
    previewLayer.session = session
    previewLayer.videoGravity = .resizeAspect
    previewLayer.connection?.videoOrientation = videoOrientation
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
}

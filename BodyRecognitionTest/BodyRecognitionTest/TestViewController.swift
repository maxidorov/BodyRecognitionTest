//
//  ViewController.swift
//  BodyRecognitionTest
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import UIKit
import AVFoundation
import VideoToolbox

class VideoOutputDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  let imageProcessor: ImageProcessor

  init(imageProcessor: ImageProcessor) {
    self.imageProcessor = imageProcessor
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
    let ciimage = CIImage(cvPixelBuffer: imageBuffer).oriented(.right)
    let context = CIContext(options: nil)
    let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!

    imageProcessor.getImageWithPoints(cgImage: cgImage)
  }
}

class TestViewController: UIViewController {
  private let videoDataOutputQueue = DispatchQueue(
    label: "CameraFeedDataOutput",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem
  )

  private let session: AVCaptureSession
  private let videoOutputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate
  private let processedImageView: UIImageView
  private let imageProcessor: ImageProcessor
  private let squatsСounterView: UILabel
  private var squatsCounter: Int = 0 {
    didSet {
      onMainThreadAsync {
        self.squatsСounterView.text = String(self.squatsCounter)
      }
    }
  }

  init() {
    imageProcessor = ImageProcessor()

    processedImageView = UIImageView()

    videoOutputDelegate = VideoOutputDelegate(imageProcessor: imageProcessor)
    
    session = try! CaptureSessionFactory.makeSession(
      outputDelegate: videoOutputDelegate,
      outputQueue: videoDataOutputQueue
    )
    
    squatsСounterView = {
      let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 60.0)
      label.textColor = .green
      label.text = "0"
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
    }()
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageProcessor.delegate = self
    
    session.startRunning()
    view.addSubview(processedImageView)
    processedImageView.addSubview(squatsСounterView)
    squatsСounterView.centerXAnchor.constraint(equalTo: processedImageView.centerXAnchor).isActive = true
    squatsСounterView.centerYAnchor.constraint(equalTo: processedImageView.centerYAnchor).isActive = true
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    processedImageView.frame = view.bounds
  }
}

extension TestViewController: ImageProcessing {
  
  func didSquat() {
    squatsCounter += 1
  }
  
  func update(image: UIImage) {
    processedImageView.image = image
  }
  
}

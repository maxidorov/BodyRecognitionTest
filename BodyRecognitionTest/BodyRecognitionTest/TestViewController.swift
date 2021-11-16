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
  private let imageProcessorDelegate: ImageProcessing

  init() {
    imageProcessor = ImageProcessor()

    processedImageView = UIImageView()

    imageProcessorDelegate = ImageProcessingImpl(imageContainer: processedImageView)
    imageProcessor.delegate = imageProcessorDelegate

    videoOutputDelegate = VideoOutputDelegate(imageProcessor: imageProcessor)
    
    session = try! CaptureSessionFactory.makeSession(
      outputDelegate: videoOutputDelegate,
      outputQueue: videoDataOutputQueue
    )

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    session.startRunning()
    view.addSubview(processedImageView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    processedImageView.frame = view.bounds
  }
}

extension TestViewController: ImageProcessing {
  func update(image: UIImage) {
    processedImageView.image = image
  }
}

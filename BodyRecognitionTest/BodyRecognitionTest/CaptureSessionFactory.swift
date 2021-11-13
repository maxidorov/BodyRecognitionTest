//
//  CaptureSessionFactory.swift
//  BodyRecognitionTest
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import Foundation
import AVFoundation

enum CustomError: Error {
  case somethingWentWrong
}

final class CaptureSessionFactory {
  static func makeSession(
    outputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate,
    outputQueue: DispatchQueue
  ) throws -> AVCaptureSession {
    let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [wideAngle],
      mediaType: .video,
      position: .unspecified
    )

    guard let videoDevice = discoverySession.devices.first else {
      throw CustomError.somethingWentWrong
      //      throw AppError.captureSessionSetup(reason: "Could not find a wide angle camera device.")
    }

    guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
      throw CustomError.somethingWentWrong
      //      throw AppError.captureSessionSetup(reason: "Could not create video device input.")
    }

    let session = AVCaptureSession()
    session.beginConfiguration()

    let support1920x1080 = videoDevice.supportsSessionPreset(.hd1920x1080)
    session.sessionPreset = support1920x1080 ? .hd1920x1080 : .high

    guard session.canAddInput(deviceInput) else {
      throw CustomError.somethingWentWrong
      //      throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
    }
    session.addInput(deviceInput)

    let dataOutput = AVCaptureVideoDataOutput()
    if session.canAddOutput(dataOutput) {
      session.addOutput(dataOutput)

      dataOutput.alwaysDiscardsLateVideoFrames = true

      let videoSettingKey = String(kCVPixelBufferPixelFormatTypeKey)
      let videoSettingValue = Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
      dataOutput.videoSettings = [videoSettingKey: videoSettingValue]
      dataOutput.setSampleBufferDelegate(outputDelegate, queue: outputQueue)
    } else {
      throw CustomError.somethingWentWrong
      //      throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
    }

    let captureConnection = dataOutput.connection(with: .video)
    captureConnection?.preferredVideoStabilizationMode = .standard
    captureConnection?.isEnabled = true

    session.commitConfiguration()

    return session
  }
}

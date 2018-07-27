//
//  CameraHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/22/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import AVKit
import CoreMotion

public enum CameraState {
    case ready, accessDenied, noDeviceFound, notDetermined
}

public enum CameraOutputQuality: Int {
    case low, medium, high
}

class CameraManager: NSObject {

    open var showAccessPermissionPopupAutomatically = true
    open var showErrorsToUsers = true
    open var captureSession: AVCaptureSession?
    fileprivate var coreMotionManager: CMMotionManager!
    fileprivate var sessionQueue: DispatchQueue = DispatchQueue(label: "CameraSessionQueue", attributes: [])
    fileprivate var deviceOrientation: UIDeviceOrientation = .portrait
    fileprivate var cameraIsSetup = false
    fileprivate var cameraIsObservingDeviceOrientation = false
    var cameraPosition = AVCaptureDevice.Position.front

    open var cameraIsReady: Bool {
        get {
            return cameraIsSetup
        }
    }

    open var hasFrontCamera: Bool = {
        let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        return frontDevice != nil
    }()

    open var focusMode : AVCaptureDevice.FocusMode = .continuousAutoFocus
    
    fileprivate lazy var mic: AVCaptureDevice? = {
        return AVCaptureDevice.default(for: AVMediaType.audio)
    }()
    
    fileprivate lazy var frontCameraDevice: AVCaptureDevice? = {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }()
    
    open var showErrorBlock:(_ erTitle: String, _ erMessage: String) -> Void = { (erTitle: String, erMessage: String) -> Void in
        var alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
        
        NavigationHelper.getCurrentVC()?.present(alertController, animated: true, completion:nil)
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupCamera() {
        self.captureSession = AVCaptureSession()
        if let inputs = self.captureSession?.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession?.removeInput(input)
            }
        }
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        self.captureSession?.addInput(input)
    }
    
    func startSession() {
        self.captureSession?.sessionPreset = .medium
        self.captureSession?.startRunning()

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
        self.captureSession?.addOutput(dataOutput)
    }

    func stopCaptureSession() {
        self.captureSession?.stopRunning()
        
        if let inputs = captureSession?.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession?.removeInput(input)
            }
        }
    }

    open func stopAndRemoveCaptureSession() {
        self.stopCaptureSession()
        self.cameraIsSetup = false
        self.captureSession = nil
        self.frontCameraDevice = nil
        self.mic = nil
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera was able to capture frame")
    }
}

extension CameraManager {
    
    fileprivate func canLoadCamera() -> Bool {
        let currentCameraState = checkIfCameraIsAvailable()
        return currentCameraState == .ready || (currentCameraState == .notDetermined && showAccessPermissionPopupAutomatically)
    }

    open func askUserForCameraPermission(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (allowedAccess) -> Void in
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (allowedAccess) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(allowedAccess)
                })
            })
        })
    }
    
    fileprivate func checkIfCameraIsAvailable() -> CameraState {
        let deviceHasCamera = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) || UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
        if deviceHasCamera {
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let userAgreedToUseIt = authorizationStatus == .authorized
            if userAgreedToUseIt {
                return .ready
            } else if authorizationStatus == AVAuthorizationStatus.notDetermined {
                return .notDetermined
            } else {
                self.show(NSLocalizedString("Camera access denied", comment:""), message:NSLocalizedString("You need to go to settings app and grant acces to the camera device to use it.", comment:""))
                return .accessDenied
            }
        } else {
            self.show(NSLocalizedString("Camera unavailable", comment:""), message:NSLocalizedString("The device does not have a camera.", comment:""))
            return .noDeviceFound
        }
    }
    
    fileprivate func show(_ title: String, message: String) {
        if showErrorsToUsers {
            DispatchQueue.main.async(execute: { () -> Void in
                self.showErrorBlock(title, message)
            })
        }
    }
}


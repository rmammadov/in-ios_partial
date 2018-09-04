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
    fileprivate var cameraPosition = AVCaptureDevice.Position.front
    fileprivate var gazeTracker: Any?
    fileprivate var gazeTrackingCompleted: Bool = true
    fileprivate var cameraView: UIView? // For the test purpose

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
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) -> Void in  }))
        
        NavigationHelper.getCurrentVC()?.present(alertController, animated: true, completion:nil)
    }
    
    init(cameraView: UIView) {
        super.init()
        // TODO: Remove after tests
        self.cameraView = cameraView // For the test purpose
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func setCamera() {
        if self.canLoadCamera() {
            self.captureSession = AVCaptureSession()
            if let inputs = self.captureSession?.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    self.captureSession?.removeInput(input)
                }
            }
            
            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.cameraPosition) else {return}
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
            self.captureSession?.addInput(input)
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if self.captureSession != nil {
                self.captureSession?.sessionPreset = .medium
                self.captureSession?.startRunning()

                DispatchQueue.main.async {
                    // TODO: Remove this after tests
                    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                    previewLayer.connection?.videoOrientation = .landscapeLeft
                    self.cameraView?.layer.addSublayer(previewLayer)
                    previewLayer.frame = (self.cameraView?.frame)!
                }
                
                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
                self.captureSession?.addOutput(dataOutput)
            }
        }
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
        predicate(frame: sampleBuffer.image(orientation: .down, scale: 1.0)!)
    }
}

extension CameraManager {
    
    fileprivate func canLoadCamera() -> Bool {
        let currentCameraState = checkIfCameraIsAvailable()
        return currentCameraState == .ready || (currentCameraState == .notDetermined && showAccessPermissionPopupAutomatically)
    }

    open func askUserForCameraPermission(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (allowedAccess) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completion(allowedAccess)
            })
        })
    }
    
    fileprivate func checkIfCameraIsAvailable() -> CameraState {
        let deviceHasCamera = hasFrontCamera
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

extension CameraManager: GazePredictionDelegate {
    
    func setPrediction() {
        if #available(iOS 11.0, *)  {
            gazeTracker = GazeTracker(delegate: self)
        } else {
            return
        }
    }
    
    func predicate(frame: UIImage) {
        if self.gazeTrackingCompleted {
            if #available(iOS 11.0, *)  {
                self.gazeTrackingCompleted = false
                let gazeTracker: GazeTracker = self.gazeTracker as! GazeTracker
                gazeTracker.startPredictionInBackground(scene: frame.fixedOrientation())
            } else {
                return
            }
        }
    }
    
    func didUpdatePrediction() {
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                self.isFaceDetected(status: true)
            }
            let gazeTracker: GazeTracker = self.gazeTracker as! GazeTracker
            print("Values: \(gazeTracker.gazeEstimation)")
            self.gazeTrackingCompleted = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func isFaceDetected(status: Bool) {
        if status {
            self.cameraView?.layer.borderWidth = 10
            self.cameraView?.layer.borderColor = UIColor.red.cgColor
        } else {
            self.cameraView?.layer.borderWidth = 0
            self.cameraView?.layer.borderColor = UIColor.black.cgColor
        }
    }
}


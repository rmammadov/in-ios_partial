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
    fileprivate var gazeTracker: GazeTracker?
    fileprivate var cameraView: UIImageView? // For the test purpose
    fileprivate weak var processingImage: UIImage?
    fileprivate var label: UILabel?
    fileprivate var previewLayer: UIView?
    fileprivate var validPreviewLayer: AVCaptureVideoPreviewLayer?

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
    
    open var shouldRespondToOrientationChanges = true {
        didSet {
            if shouldRespondToOrientationChanges {
                _startFollowingDeviceOrientation()
            } else {
//                _stopFollowingDeviceOrientation()
            }
        }
    }
    
    init(cameraView: UIImageView) {
        super.init()
        // TODO: Remove after tests
        self.cameraView = cameraView // For the test purpose
        addPreviewLayer()
        addLabel();
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
    
    fileprivate func addPreviewLayer() {
        self.previewLayer = UIView(frame: CGRect(x: 10, y: (self.cameraView?.bounds.height)! - 600.0, width: 350.0, height: 600.0))
        self.cameraView?.addSubview(self.previewLayer!)
        self.cameraView?.layer.zPosition = .greatestFiniteMagnitude
    }
    
    fileprivate func addLabel() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 300.0, height: 24.0))
        let centerX = label!.bounds.width / 2 + 48.0
        let centerY = (self.cameraView?.bounds.height)! - label!.bounds.height / 2 - 32.0
        label?.center = CGPoint(x: centerX, y: centerY)
        label?.textAlignment = .left
        label?.textColor = .red
        label?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        label?.text = "Coordinates"
        self.cameraView?.addSubview(label!)
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
                self.captureSession?.sessionPreset = .high
                self.captureSession?.startRunning()
                
                DispatchQueue.main.async {
                    // TODO: Remove this after tests
                    self.validPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                    self.validPreviewLayer!.connection?.videoOrientation = self._videoOrientation(forDeviceOrientation: self.deviceOrientation)
                    self.previewLayer?.layer.addSublayer(self.validPreviewLayer!)
                    self.validPreviewLayer!.frame = (self.previewLayer?.frame)!
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
        if (self.processingImage == nil) {
            
//            guard let capturedImage = sampleBuffer.image(orientation: .leftMirrored, scale: 1.0)?.rotate(radians: 0) else {return}
            guard let capturedImage = UIImage(named: "test_image") else {return} // Use static image to uncomment this line and comment previous
            
            self.processingImage = capturedImage //save weak reference to know when prediction is completed
            predicate(frame: capturedImage)
        }
    }
    
}

extension CameraManager: GazePredictionDelegate {
    
    func setPrediction() {
        gazeTracker = GazeTracker(delegate: self)
    }
    
    func predicate(frame: UIImage) {
        let gazeTracker: GazeTracker = self.gazeTracker!
        gazeTracker.startPredictionInBackground(scene: frame)
    }
    
    func didUpdatePrediction() {
        self.isFaceDetected(status: true)
        let gazeTracker: GazeTracker = self.gazeTracker!
        if gazeTracker.gazeEstimation == nil {
            self.label?.text = "nil"
        } else {
            self.label?.text = "Values: X: \(String(describing: gazeTracker.gazeEstimation![0]))" + " Y: \(String(describing: gazeTracker.gazeEstimation![0]))"
        }
    }
    
    func isFaceDetected(status: Bool) {
        DispatchQueue.main.async {
            if status {
                self.cameraView?.layer.borderWidth = 10
                self.cameraView?.layer.borderColor = UIColor.red.cgColor
            } else {
                self.cameraView?.layer.borderWidth = 0
                self.cameraView?.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
}


extension CameraManager {
    
    fileprivate func _orientationChanged() {
        if let validPreviewLayer = self.validPreviewLayer, let connection = validPreviewLayer.connection  {
              self.validPreviewLayer!.connection?.videoOrientation = self._videoOrientation(forDeviceOrientation: self.deviceOrientation)
        }
    }
    
    fileprivate func _startFollowingDeviceOrientation() {
        if shouldRespondToOrientationChanges && !cameraIsObservingDeviceOrientation {
            coreMotionManager = CMMotionManager()
            coreMotionManager.accelerometerUpdateInterval = 0.005
            
            if coreMotionManager.isAccelerometerAvailable {
                coreMotionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler:
                    {data, error in
                        
                        guard let acceleration: CMAcceleration = data?.acceleration  else{
                            return
                        }
                        
                        let scaling: CGFloat = CGFloat(1) / CGFloat(( abs(acceleration.x) + abs(acceleration.y)))
                        
                        let x: CGFloat = CGFloat(acceleration.x) * scaling
                        let y: CGFloat = CGFloat(acceleration.y) * scaling
                        
                        if acceleration.z < Double(-0.75) {
                            self.deviceOrientation = .faceUp
                        } else if acceleration.z > Double(0.75) {
                            self.deviceOrientation = .faceDown
                        } else if x < CGFloat(-0.5) {
                            self.deviceOrientation = .landscapeLeft
                        } else if x > CGFloat(0.5) {
                            self.deviceOrientation = .landscapeRight
                        } else if y > CGFloat(0.5) {
                            self.deviceOrientation = .portraitUpsideDown
                        }
                        
                         self._orientationChanged()
                })
                
                cameraIsObservingDeviceOrientation = true
            } else {
                cameraIsObservingDeviceOrientation = false
            }
        }
    }
    
    
    fileprivate func _imageOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation, isMirrored: Bool) -> UIImage.Orientation {
        
        switch deviceOrientation {
        case .landscapeLeft:
            return isMirrored ? .upMirrored : .up
        case .landscapeRight:
            return isMirrored ? .downMirrored : .down
        default:
            break
        }
        
        return isMirrored ? .leftMirrored : .right
    }
    
    fileprivate func fixOrientation(withImage image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        var isMirrored = false
        let orientation = image.imageOrientation
        if orientation == .rightMirrored
            || orientation == .leftMirrored
            || orientation == .upMirrored
            || orientation == .downMirrored {
            
            isMirrored = true
        }
        
        let newOrientation = _imageOrientation(forDeviceOrientation: deviceOrientation, isMirrored: isMirrored)
        
        if image.imageOrientation != newOrientation {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: newOrientation)
        }
        
        return image
    }
    
    fileprivate func _currentCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        
        if deviceOrientation == .faceDown
            || deviceOrientation == .faceUp
            || deviceOrientation == .unknown {
            return _currentPreviewVideoOrientation()
        }
        
        return _videoOrientation(forDeviceOrientation: deviceOrientation)
    }
    
    fileprivate func _currentPreviewVideoOrientation() -> AVCaptureVideoOrientation {
        let orientation = _currentPreviewDeviceOrientation()
        return _videoOrientation(forDeviceOrientation: orientation)
    }
    
    fileprivate func _currentPreviewDeviceOrientation() -> UIDeviceOrientation {
            return .portrait
        
        return UIDevice.current.orientation
    }
    
    fileprivate func _videoOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch deviceOrientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .faceUp:
            /*
             Attempt to keep the existing orientation.  If the device was landscape, then face up
             getting the orientation from the stats bar would fail every other time forcing it
             to default to portrait which would introduce flicker into the preview layer.  This
             would not happen if it was in portrait then face up
             */
            if let validPreviewLayer = self.validPreviewLayer, let connection = validPreviewLayer.connection  {
                return connection.videoOrientation //Keep the existing orientation
            }
            //Could not get existing orientation, try to get it from stats bar
            return _videoOrientationFromStatusBarOrientation()
        case .faceDown:
            /*
             Attempt to keep the existing orientation.  If the device was landscape, then face down
             getting the orientation from the stats bar would fail every other time forcing it
             to default to portrait which would introduce flicker into the preview layer.  This
             would not happen if it was in portrait then face down
             */
            if let validPreviewLayer = self.validPreviewLayer, let connection = validPreviewLayer.connection  {
                return connection.videoOrientation //Keep the existing orientation
            }
            //Could not get existing orientation, try to get it from stats bar
            return _videoOrientationFromStatusBarOrientation()
        default:
            return .portrait
        }
    }
    
    fileprivate func _videoOrientationFromStatusBarOrientation() -> AVCaptureVideoOrientation {
        
        var orientation: UIInterfaceOrientation?
        
        DispatchQueue.main.async {
            orientation = UIApplication.shared.statusBarOrientation
        }
        
        /*
         Note - the following would fall into the guard every other call (it is called repeatedly) if the device was
         landscape then face up/down.  Did not seem to fail if in portrait first.
         */
        guard let statusBarOrientation = orientation else {
            return .portrait
        }
        
        switch statusBarOrientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }

}


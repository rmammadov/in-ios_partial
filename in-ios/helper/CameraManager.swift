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
    fileprivate var deviceOrientation: UIDeviceOrientation = .unknown
    fileprivate var cameraIsSetup = false
    fileprivate var cameraIsObservingDeviceOrientation = false
    fileprivate var cameraPosition = AVCaptureDevice.Position.front
    fileprivate var gazeTracker: GazeTracker?
    fileprivate var cameraView: UIView? // For the test purpose
    fileprivate weak var processingImage: UIImage?
    fileprivate var label: UILabel?
    fileprivate var previewLayer: UIImageView?
    fileprivate var dataOutput: AVCaptureVideoDataOutput?
    fileprivate var ivPointer: UIImageView?
    fileprivate var imagePointerRed: UIImage?
    fileprivate var imagePointerYellow: UIImage?
    fileprivate var averageX: [Double] = Array(repeating: 0.0, count: 3)
    fileprivate var averageY: [Double] = Array(repeating: 0.0, count: 3)
    fileprivate var averagingCount: Double = 0

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
    
    init(cameraView: UIView) {
        super.init()
        // TODO: Remove after tests
        self.cameraView = cameraView // For the test purpose
        addPreviewLayer()
        addLabel();
        addPointer();
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
        self.previewLayer = UIImageView()
        
        self.previewLayer?.contentMode = .scaleAspectFit
        self.cameraView?.addSubview(self.previewLayer!)
        
        self.previewLayer?.translatesAutoresizingMaskIntoConstraints = false
        self.previewLayer?.leftAnchor.constraint(equalTo: (self.cameraView?.leftAnchor)!, constant: 10).isActive=true
        self.previewLayer?.topAnchor.constraint(equalTo: (self.cameraView?.bottomAnchor)!, constant: -350).isActive=true
        self.previewLayer?.rightAnchor.constraint(equalTo: (self.cameraView?.leftAnchor)!, constant: 330).isActive=true
        self.previewLayer?.bottomAnchor.constraint(equalTo: (self.cameraView?.bottomAnchor)!, constant: -34).isActive=true

        self.cameraView?.layer.zPosition = .greatestFiniteMagnitude
    }
    
    fileprivate func addLabel() {
        label = UILabel()
        label?.textAlignment = .center
        label?.textColor = .red
        label?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        label?.text = "Coordinates"
        self.cameraView?.addSubview(label!)
        
        label?.translatesAutoresizingMaskIntoConstraints = false
        label?.leftAnchor.constraint(equalTo: (self.cameraView?.leftAnchor)!, constant: 10).isActive=true
        label?.topAnchor.constraint(equalTo: (self.cameraView?.bottomAnchor)!, constant: -34).isActive=true
        label?.rightAnchor.constraint(equalTo: (self.cameraView?.leftAnchor)!, constant: 330).isActive=true
        label?.bottomAnchor.constraint(equalTo: (self.cameraView?.bottomAnchor)!, constant: -10).isActive=true

    }
    
    fileprivate func addPointer() {
        imagePointerRed = UIImage(named: "ic_pointer_red")
        imagePointerYellow = UIImage(named: "ic_pointer_yellow")
        ivPointer = UIImageView(image: imagePointerRed!)
        ivPointer?.contentMode = .scaleAspectFill
    }

    fileprivate func setPointerActive() {
        ivPointer?.image = imagePointerYellow
    }

    fileprivate func setPointerPassive() {
        ivPointer?.image = imagePointerRed
    }
    
    fileprivate func updatePointer(x: Double, y: Double) {
        print("Coordinates x: \(x)" + " y: \(y)")
        ivPointer?.frame = CGRect(x: x, y: y, width: 50.0, height: 55.0)
        cameraView!.addSubview(ivPointer!)
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
                self.captureSession?.sessionPreset = Constant.DefaultConfig.RESOLUTION_VIDEO_INPUT
                self.captureSession?.startRunning()

                self.deviceOrientation = UIDevice.current.orientation;
                
                let videoOrientation = self._videoOrientation(forDeviceOrientation: self.deviceOrientation);
                
                DispatchQueue.main.async {
                    // TODO: Remove this after tests

                    //J.V. commented this out because using hardware preview is not very useful
                    //for verifying the image orientation sent to the gaze tracker
                    
                    /*
                    self.validPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                    self.validPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    
                    self.validPreviewLayer!.connection?.videoOrientation = videoOrientation
                    self.previewLayer?.layer.addSublayer(self.validPreviewLayer!)
                    self.validPreviewLayer!.frame = (self.previewLayer?.frame)!
                    */
                }
                
                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
                dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
                self.captureSession?.addOutput(dataOutput)
                dataOutput.connection(with: AVMediaType.video)?.videoOrientation = videoOrientation
                self.dataOutput = dataOutput;
                
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
            
            guard let capturedImage = sampleBuffer.image(orientation: .up, scale: 1.0)?.rotate(radians: 0) else {return}
//            guard let capturedImage = UIImage(named: "test_image") else {return} // Use static image to uncomment this line and comment previous
            
            if let cgImage = capturedImage.cgImage?.copy()
            {
                //must duplicate the image to avoid a retain cycle on our weak reference
                let newImage = UIImage(cgImage: cgImage,
                                       scale: capturedImage.scale,
                                       orientation: capturedImage.imageOrientation)
                
                DispatchQueue.main.async {
                    self.previewLayer?.image = newImage;
                }
            }
            
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
        guard let gazeTracker = gazeTracker else { return }
        gazeTracker.startPredictionInBackground(scene: frame)
    }
    
    func didUpdatePrediction(status: Bool) {
        let gazeTracker: GazeTracker = self.gazeTracker!
        if !status {
            self.label?.text = "nil"
            setPointerPassive()
        } else {
            self.label?.text = "Values: X: \(String(describing: gazeTracker.gazeEstimation![0]))" + " Y: \(String(describing: gazeTracker.gazeEstimation![1]))"
            
            averageX.remove(at: 0)
            averageX.append(Double(truncating: gazeTracker.gazeEstimation![0]))
            
            averageY.remove(at: 0)
            averageY.append(Double(truncating: gazeTracker.gazeEstimation![1]))
            
            let X = averageX.reduce(0, +)/Double(averageX.count)
            let Y = averageY.reduce(0, +)/Double(averageY.count)
            
            let coordinates = gazeTracker.cm2pixels(gazeX: X, gazeY: Y, camX: 0, camY: 12.0, orientation: UIDevice.current.orientation)
            updatePointer(x: coordinates.gazeX, y: coordinates.gazeY)
            setPointerActive()
        }
        
//        self.isFaceDetected(status: status)
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
        //self.validPreviewLayer?.connection?.videoOrientation = self._videoOrientation(forDeviceOrientation: self.deviceOrientation)
        
        if let outputs = captureSession?.outputs {
            for output in outputs {
                output.connection(with: AVMediaType.video)!.videoOrientation = self._videoOrientation(forDeviceOrientation: self.deviceOrientation)
            }
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
                        
                        var newOrientation:UIDeviceOrientation = .unknown
                        
                        let scaling: CGFloat = CGFloat(1) / CGFloat(( abs(acceleration.x) + abs(acceleration.y)))
                        
                        let x: CGFloat = CGFloat(acceleration.x) * scaling
                        let y: CGFloat = CGFloat(acceleration.y) * scaling
                        
                        if acceleration.z < Double(-0.75) {
                            newOrientation = .faceUp
                        } else if acceleration.z > Double(0.75) {
                            newOrientation = .faceDown
                        } else if x < CGFloat(-0.5) {
                            newOrientation = .landscapeLeft
                        } else if x > CGFloat(0.5) {
                            newOrientation = .landscapeRight
                        } else if y < CGFloat(-0.5) {
                            newOrientation = .portrait
                        } else if y > CGFloat(0.5) {
                            newOrientation = .portraitUpsideDown
                        }
                        
                        if (newOrientation != self.deviceOrientation)
                        {
                            self.deviceOrientation = newOrientation;
                            self._orientationChanged()
                        }
                        
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
            if let dataOutput = self.dataOutput, let connection = dataOutput.connection(with: AVMediaType.video) {
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
            if let dataOutput = self.dataOutput, let connection = dataOutput.connection(with: AVMediaType.video) {
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


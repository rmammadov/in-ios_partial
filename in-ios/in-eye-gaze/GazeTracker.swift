//
//  GazeTracker.swift
//  INGazeTracking
//
//  Created by Alexandre Drouin-Picaro on 2018-08-04.
//  Copyright © 2018 innodem-neurosciences. All rights reserved.
//

import Foundation
import Firebase
import Accelerate
import CoreML

@available(iOS 11.0, *)
public class GazeTracker: FaceFinderDelegate {
    
    let model = GazeEstimator()
    let EYE_RESIZE_HEIGHT: Int = 40
    let ILLUM_ETA: Int = 3
    let ILLUM_N: Float = 0.1
    let LAPLACE_OPERATOR: [Float] = [0.0, 1.0, 0.0,
                                     1.0, -4.0, 1.0,
                                     0.0, 1.0, 0.0]
    let AVERAGING_FILTER: [Float] = Array(repeating: 1.0/49.0, count: 49)
    let PREDICTION_OPTIONS = MLPredictionOptions()
    
    //Width and height of the screen of various apple devices, in millimeters.
    let DEVICES = ["iPhone 6s":                 ["width": 58.0, "height": 100.0],
                   "iPhone 6s Plus":            ["width": 58.0, "height": 100.0],
                   "iPhone SE":                 ["width": 48.0, "height": 89.0],
                   "iPhone 7":                  ["width": 58.0, "height": 100.0],
                   "iPhone 7 Plus":             ["width": 58.0, "height": 100.0],
                   "iPhone 8":                  ["width": 58.0, "height": 100.0],
                   "iPhone 8 Plus":             ["width": 58.0, "height": 100.0],
                   "iPhone X":                  ["width": 62.0, "height": 135.0],
                   "iPad Air":                  ["width": 150.0, "height": 200.0],
                   "iPad Air 2":                ["width": 150.0, "height": 200.0],
                   "iPad 5":                    ["width": 150.0, "height": 200.0],
                   "iPad 6":                    ["width": 150.0, "height": 200.0],
                   "iPad Mini 2":               ["width": 120.0, "height": 160.0],
                   "iPad Mini 3":               ["width": 120.0, "height": 160.0],
                   "iPad Mini 4":               ["width": 120.0, "height": 160.0],
                   "iPad Pro 9.7 Inch":         ["width": 150.0, "height": 200.0],
                   "iPad Pro 12.9 Inch":        ["width": 198.0, "height": 264.0],
                   "iPad Pro 12.9 Inch 2":      ["width": 198.0, "height": 264.0],
                   "iPad Pro 10.5 Inch":        ["width": 162.0, "height": 216.0]]
    
    var detector: FaceFinder? = nil
    var mainFace: VisionFace? = nil
    var gazeEstimation: MLMultiArray? = nil
    var predictionDelegate: GazePredictionDelegate? = nil
    
    var deviceName: String = ""
    var screenWidthMil: Double = 0, screenHeightMil: Double = 0
    var screenWidthPix: Double = 0, screenHeightPix: Double = 0
    var PPCM: [Double] = [0.0, 0.0]
    var illumResizeRatio: Double = 1.0
    var frameReceived:Int = 0
    let frameSubSampleInterval = 12;
    
    /**
     Initializer
     */
    init(delegate: GazePredictionDelegate?, illumResizeRatio: Double = 1.0) {
        self.detector = FaceFinder()
        self.detector?.delegate = self
        self.predictionDelegate = delegate
        
        self.PREDICTION_OPTIONS.usesCPUOnly = true
        
        self.deviceName = UIDevice.current.modelName
        self.screenWidthMil = self.DEVICES[self.deviceName]!["width"]!
        self.screenHeightMil = self.DEVICES[self.deviceName]!["height"]!
        self.screenWidthPix = Double(UIScreen.main.fixedCoordinateSpace.bounds.size.width)
        self.screenHeightPix = Double(UIScreen.main.fixedCoordinateSpace.bounds.size.height)
        self.PPCM = [self.screenWidthPix/(self.screenWidthMil/10.0),
                     self.screenHeightPix/(self.screenHeightMil/10.0)]
        self.illumResizeRatio = illumResizeRatio
    }
    
    static func deg2rad(degrees: Double) -> Double {return degrees * .pi / 180}
    
    static func rotateImage(image: UIImage, degrees: Double) -> UIImage? {
        if degrees == 0 { return image }
        
        guard let cgImage = image.cgImage else { return nil }
        
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(deg2rad(degrees: degrees)))
        rotatedViewBox.transform = t
        
        let newSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(newSize)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        //Rotate the image context
        context.rotate(by: CGFloat(deg2rad(degrees: degrees)))
        //Now, draw the rotated/scaled image into the context
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     Converts the coordinates of the gaze estimate from centimeters from the camera to pixels from screen center.
     
     - Parameter gazeX: the X position of the gaze as estimated by the model.
     - Parameter gazeY: the Y position of the gaze as estimated by the model.
     - Parameter camX: the horizontal position of the camera relative to the center of the device when in portrait mode, in centimeters.
     - Parameter camY: the vertical position of the camera relative to the center of the device when in portrait mode, in centimeters.
     - Parameter orientation: The current orientation of the device.
     */
    func cm2pixels(gazeX: Double, gazeY: Double, camX: Double, camY: Double, orientation: UIDeviceOrientation) -> (gazeX: Int, gazeY: Int) {
        
        var gazeXFromCenter: Double = 0, gazeYFromCenter: Double = 0 //Distance of gaze from center in centimenters
        var pixelsX: Int = 0, pixelsY: Int = 0 //Distance of gaze from center in pixels
        
        switch orientation {
        case .portraitUpsideDown:
            gazeXFromCenter = gazeX - camX
            gazeYFromCenter = gazeY - camY
            pixelsX = Int(gazeXFromCenter * self.PPCM[0])
            pixelsY = Int(gazeYFromCenter * self.PPCM[1])
        case .landscapeLeft:
            gazeXFromCenter = gazeX - camY
            gazeYFromCenter = gazeY + camX
            pixelsX = Int(gazeXFromCenter * self.PPCM[1])
            pixelsY = Int(gazeYFromCenter * self.PPCM[0])
        case .landscapeRight:
            gazeXFromCenter = gazeX + camY
            gazeYFromCenter = gazeY - camX
            pixelsX = Int(gazeXFromCenter * self.PPCM[1])
            pixelsY = Int(gazeYFromCenter * self.PPCM[0])
        default:
            gazeXFromCenter = gazeX + camX
            gazeYFromCenter = gazeY + camY
            pixelsX = Int(gazeXFromCenter * self.PPCM[0])
            pixelsY = Int(gazeYFromCenter * self.PPCM[1])
        }
        
        return (pixelsX, pixelsY)
    }
    
    /**
     Predict the gaze position of the central face in the scene.
     
     - Parameter scene: Any image. Should come from front-facing camera of the device. The imageOrientation property should be UP.
     
     Steps:
     - Estimate illuminant from the image (Yields model input)
     - Detect the faces
     - Select the central face as the main face
     - Get the facial features from the face
     - Aggregate the facial features, except for the eye positions, into an MLMultiArray. This array will be one-dimensional and will contain the X and Y positions of the facial features. (Yields model input)
     - Using the position of the eyes, crop out two square images, one around each eye. Concatenate the images, split them along the color channel axis and cast them into MLMultiArrays (Yields model input)
     - Normalize features
     */
    public func startPrediction(scene: UIImage) {
        var rotatedImage: UIImage?
        
        switch scene.imageOrientation {
        case .left:
            rotatedImage = GazeTracker.rotateImage(image: scene, degrees: -90)
        case .down:
            rotatedImage = GazeTracker.rotateImage(image: scene, degrees: 180)
        case .right:
            rotatedImage = GazeTracker.rotateImage(image: scene, degrees: 90)
        default:
            rotatedImage = scene
        }
        
        guard let image = rotatedImage else { return }
        self.detector?.getFaces(scene: image)
    }
    
    /**
     Runs the gaze estimation in the background
    */
    public func startPredictionInBackground(scene: UIImage) {
        
        //quick fix to avoid overflowing the DispatchQueue
        //will need a more permanent pacing mechanism to post only as fast as algo can process
        //for now tweak the frameSubsampleInterval if device is too slow
        
        frameReceived += 1;
        if (frameReceived % frameSubSampleInterval != 1)
        {
            return;
        }

        DispatchQueue.global(qos: .background).async {

            var rotatedImage: UIImage?
            
            switch scene.imageOrientation {
            case .left:
                rotatedImage = GazeTracker.rotateImage(image: scene, degrees: -90)
            case .down:
                rotatedImage = GazeTracker.rotateImage(image: scene, degrees: 180)
            case .right:
                rotatedImage = GazeTracker.rotateImage(image: scene, degrees: 90)
            default:
                rotatedImage = scene
            }
            
            guard let image = rotatedImage else { return }
            self.detector?.getFaces(scene: image)
        }
    }
    
    public func didFindFaces(scene: UIImage) {
        getMainFace()
        let facialFeatures: MLMultiArray = self.getFacialFeatures()
        let eyes = self.getEyes(image: scene)
        guard let leftEye = eyes.leftEYe, let rightEye = eyes.rightEye else{
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction()
            return
        }
        
        guard let eyesImage = self.concatenateEyes(leftEye: leftEye, rightEye: rightEye) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction()
            return
        }

        guard let eyeChannels = self.channels2MLMultiArray(image: eyesImage) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction()
            return
        }
        
        guard let illuminant = self.estimateIlluminant(image: scene) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction()
            return
        }
        
        let pred = self.predictGaze(eyesB: eyeChannels.blueChannel, eyesG: eyeChannels.greenChannel, eyesR: eyeChannels.redChannel, illuminant: illuminant, headPose: facialFeatures)
        self.gazeEstimation = pred
        self.predictionDelegate?.didUpdatePrediction()
    }
    
    private func getMainFace() {
        var tempFace: VisionFace? = nil
        for face in self.detector!.faces! {
            if tempFace == nil {
                tempFace = face
            } else {
                if tempFace!.frame.width < face.frame.width {
                    tempFace = face
                }
            }
        }
        self.mainFace = tempFace
    }
    
    public func getFacialFeatures() -> MLMultiArray {
        //        TODO: Clean up code, deal with missing features more gracefully
        var features = [Double]()
        
        if let mouthBottom = self.mainFace?.landmark(ofType: .mouthBottom) {
            features.append(mouthBottom.position.x.doubleValue)
            features.append(mouthBottom.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let mouthLeft = self.mainFace?.landmark(ofType: .mouthLeft) {
            features.append(mouthLeft.position.x.doubleValue)
            features.append(mouthLeft.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let mouthRight = self.mainFace?.landmark(ofType: .mouthRight) {
            features.append(mouthRight.position.x.doubleValue)
            features.append(mouthRight.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let earLeft = self.mainFace?.landmark(ofType: .leftEar) {
            features.append(earLeft.position.x.doubleValue)
            features.append(earLeft.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let earRight = self.mainFace?.landmark(ofType: .rightEar) {
            features.append(earRight.position.x.doubleValue)
            features.append(earRight.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let cheekLeft = self.mainFace?.landmark(ofType: .leftCheek) {
            features.append(cheekLeft.position.x.doubleValue)
            features.append(cheekLeft.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        if let cheekRight = self.mainFace?.landmark(ofType: .rightCheek) {
            features.append(cheekRight.position.x.doubleValue)
            features.append(cheekRight.position.y.doubleValue)
        }  else {
            features.append(0)
            features.append(0)
        }
        
        if let nose = self.mainFace?.landmark(ofType: .noseBase) {
            features.append(nose.position.x.doubleValue)
            features.append(nose.position.y.doubleValue)
        } else {
            features.append(0)
            features.append(0)
        }
        
        guard let mlFeatures = try? MLMultiArray(shape:[16], dataType:MLMultiArrayDataType.double) else {
                fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        for (index, element) in features.enumerated() {
            mlFeatures[index] = (element/features.max()!) as NSNumber
        }
        
        return mlFeatures
        
    }
    
    /**
     Crops square images of both eyes from the
     */
    private func getEyes(image: UIImage) -> (leftEYe: CGImage?, rightEye: CGImage?) {
        let cgImage = image.cgImage
        var leftEyePos: VisionPoint? = nil
        var rightEyePos: VisionPoint? = nil
        
        if let leftEye = self.mainFace?.landmark(ofType: .leftEye) {
            leftEyePos = leftEye.position
        }
        if let rightEye = self.mainFace?.landmark(ofType: .rightEye) {
            rightEyePos = rightEye.position
        }
        
        let cropLen: Int = Int(abs((rightEyePos?.x.floatValue)! - (leftEyePos?.x.floatValue)!)/2 * Float(image.scale))
        let cropSize = CGSize(width: cropLen, height: cropLen)
        
        let leftOrigin = CGPoint(x: (leftEyePos?.x.intValue)! - cropLen/2,
                                 y: (leftEyePos?.y.intValue)! - cropLen/2)
        let rightOrigin = CGPoint(x: (rightEyePos?.x.intValue)! - cropLen/2,
                                  y: (rightEyePos?.y.intValue)! - cropLen/2)
        
        var leftEyeImage = cgImage?.cropping(to: CGRect(origin: leftOrigin, size: cropSize))
        var rightEyeImage = cgImage?.cropping(to: CGRect(origin: rightOrigin, size: cropSize))
        
        leftEyeImage = resizeCGImage(image: leftEyeImage!)
        rightEyeImage = resizeCGImage(image: rightEyeImage!)
        
        return (leftEyeImage, rightEyeImage)
    }
    
    /**
     Resizes an image to be a square image of side EYE_RESIZE_HEIGHT.
     
     - Parameter image: The image to be resized
     - Returns: The resized image
     */
    private func resizeCGImage(image: CGImage?) -> CGImage? {
        guard let image = image else { return nil }
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: self.EYE_RESIZE_HEIGHT,
                                      height: self.EYE_RESIZE_HEIGHT,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: image.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: image.alphaInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: EYE_RESIZE_HEIGHT, height: EYE_RESIZE_HEIGHT))
        
        return context.makeImage()
    }
    
    private func concatenateEyes(leftEye: CGImage, rightEye: CGImage) -> CGImage? {
        guard let colorSpace = leftEye.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: 2 * self.EYE_RESIZE_HEIGHT,
                                      height: self.EYE_RESIZE_HEIGHT,
                                      bitsPerComponent: leftEye.bitsPerComponent,
                                      bytesPerRow: leftEye.bytesPerRow + rightEye.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: leftEye.alphaInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(leftEye, in: CGRect(x: 0, y: 0, width: EYE_RESIZE_HEIGHT, height: EYE_RESIZE_HEIGHT))
        context.draw(rightEye, in: CGRect(x: EYE_RESIZE_HEIGHT, y: 0, width: EYE_RESIZE_HEIGHT, height: EYE_RESIZE_HEIGHT))
        
        let newImage = context.makeImage()
        return newImage
    }
    
    /**
     Converts a CGImage into three MLMultiArrays, one for each color channel of the original image.
     
     - Parameter image: A CGImage. The image is assumed to be in ARGB format.
     */
    private func channels2MLMultiArray(image: CGImage) -> (redChannel: MLMultiArray, greenChannel: MLMultiArray, blueChannel: MLMultiArray)? {
        
        let width = image.width
        let height = image.height
        
        guard let redChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard let greenChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard let blueChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: image.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: image.alphaInfo.rawValue) else { return nil }
        context.draw(image, in: CGRect(x: 0, y:0, width: width, height: height))
        let data = UnsafePointer<UInt8>(context.data?.assumingMemoryBound(to: UInt8.self))!
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = 4 * (y * width + x)
                let red: Double = Double(data[offset+1])/255.0
                let green: Double = Double(data[offset+2])/255.0
                let blue: Double = Double(data[offset+3])/255.0
                
//                if red.isNaN { red = 0.0 }
//                if green.isNaN { green = 0.0 }
//                if blue.isNaN { blue = 0.0 }
                
                redChannel[y * width + x] = red as NSNumber
                greenChannel[y * width + x] = green as NSNumber
                blueChannel[y * width + x] = blue as NSNumber
            }
        }
        
        return (redChannel, greenChannel, blueChannel)
        
    }
    
    /**
     Estimates the illuminant values of a scene.
     
     - Parameter image: the image whose illuminant will be evaluated.
     - Parameter resizeRatio: the ratio by which to resize the image prior to processing. This is meant to make the algorithm faster, and so the value should be less than or equal to 1.0.
     
     - Returns: An MLMultiArray containing three Double values, one for each color channel of the image.
     */
    private func estimateIlluminant(image: UIImage) -> MLMultiArray?{
        guard
            let cgImage = image.cgImage,
            let sourceColorSpace = cgImage.colorSpace else { return nil }
        
        let width = Int(Double(cgImage.width) * self.illumResizeRatio)
        let height = Int(Double(cgImage.height) * self.illumResizeRatio)
        let count = width*height
        let nGrey: Int = Int(0.1 * Float(count))
        
        let bytesPerRow: Int = width * cgImage.bytesPerRow/cgImage.width
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: sourceColorSpace,
                                      bitmapInfo: cgImage.alphaInfo.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y:0, width: width, height: height))
        let data = UnsafePointer<UInt8>(context.data?.assumingMemoryBound(to: UInt8.self))!
        
        //Separate color channels, normalize values to [0,1] and add infinitesimal
        //Average over the channels, keep as variable (L)
        //Compute the logarithms, keep as variable (logImage)
        var redChannel: [Float] = Array<Float>(repeating: 0.0, count: count)
        var greenChannel: [Float] = Array<Float>(repeating: 0.0, count: count)
        var blueChannel: [Float] = Array<Float>(repeating: 0.0, count: count)
        var normImage: [[Float]] = [redChannel, greenChannel, blueChannel]
        
        var L: [Float] = Array<Float>(repeating: 0.0, count: count)
        
        var redLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        var greenLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        var blueLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        let logImage: [[Float]] = [redLog, greenLog, blueLog]
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = 4 * (y * width + x)
                let index = y * width + x
                
                let red = Float(data[offset + 1])/255.0 + 1e-50
                let green = Float(data[offset + 2])/255.0 + 1e-50
                let blue = Float(data[offset + 2])/255.0 + 1e-50
                
                redChannel[index] = red
                greenChannel[index] = green
                blueChannel[index] = blue
                L[index] = [red, green, blue].reduce(0, +)/3.0
                redLog[index] = Darwin.log(red)
                greenLog[index] = Darwin.log(green)
                blueLog[index] = Darwin.log(blue)
            }
        }
        
        //Apply edge detection (Laplace) to each color channel of the log-space image. Store in variable (SDN)
        var SDN: [[Float]] = []
        for logChannel in logImage {
            let sdnPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: logChannel.count)
            sdnPointer.initialize(repeating: 0.0, count: logChannel.count)
            
            Accelerate.vDSP_f3x3(UnsafePointer<Float>(logChannel), vDSP_Length(height), vDSP_Length(width), UnsafePointer<Float>(LAPLACE_OPERATOR), sdnPointer)
            SDN.append(Array(UnsafeBufferPointer(start: sdnPointer, count: logChannel.count)))
            sdnPointer.deallocate()
        }
        
        //Average SDN over the color channels. Store in variable (aSDN)
        var aSDN: [Float] = []
        for i in 0..<count {
            aSDN.append([SDN[0][i], SDN[1][i], SDN[2][i]].reduce(0, +)/3.0)
        }
        
        //Compute constant P
        var P: [Float] = Array<Float>(repeating: 0.0, count: width*height)
        for i in 0..<count {
            let innerSum: [Float] = [pow(SDN[0][i] - aSDN[i], 2.0)/aSDN[i],
                                     pow(SDN[1][i] - aSDN[i], 2.0)/aSDN[i],
                                     pow(SDN[2][i] - aSDN[i], 2.0)/aSDN[i]]
            P[i] = sqrtf(innerSum.reduce(0, +)/Float(innerSum.count))
        }
        
        //Compute EGI from constants P and L. Store in variable.
        var temp: [Float] = Array<Float>(repeating: 0.0, count: count)
        for i in 0..<count { temp[i] = P[i]/L[i] }
        let egiPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: count)
        egiPointer.initialize(repeating: 0.0, count: count)
        Accelerate.vDSP_imgfir(UnsafePointer<Float>(temp), vDSP_Length(height), vDSP_Length(width), UnsafePointer<Float>(AVERAGING_FILTER), egiPointer, 7, 7)
        let EGI: [Float] = Array(UnsafeBufferPointer(start: egiPointer, count:count))
        
        //Compute GPn
        let threshold: Float = EGI.sorted {$0 > $1}[nGrey]
        var GPn: [Int] = []
        for (i, val) in EGI.enumerated() {
            if val < threshold { GPn.append(i) }
        }
        
        //Compute the illuminant values
        var e_i: [Float] = Array<Float>(repeating: 1.0, count: 3)
        for i in 0...2 {
            var channelGreys: [Float] = Array<Float>(repeating: 0.0, count: GPn.count)
            for (j, index) in GPn.enumerated() { channelGreys[j] = normImage[i][index] }
            e_i[i] = channelGreys.reduce(0, +)/Float(nGrey)
        }
        
        e_i = e_i.map {$0/e_i.max()!}
        
        //Catch any NaN and replace it by 1.0
//        e_i = e_i.map {
//            if $0.isNaN { return 1.0 }
//            return $0
//        }
        
        //Create the MLMultiArray, populate it and return it
        guard let illuminant = try? MLMultiArray(shape: [3], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for i in 0...2 {
            illuminant[i] = e_i[i] as NSNumber
        }
        
        return illuminant
    }
    
    private func predictGaze(eyesB: MLMultiArray, eyesG: MLMultiArray, eyesR: MLMultiArray, illuminant: MLMultiArray, headPose: MLMultiArray) -> MLMultiArray? {
        do {
            let modelOutput = try model.prediction(input: GazeEstimatorInput(eyesB: eyesB, eyesG: eyesG, eyesR: eyesR, illum: illuminant, pose: headPose), options: self.PREDICTION_OPTIONS)
            return modelOutput.gazeXY
        } catch {
            print(error)
            return nil
        }
    }
    
}

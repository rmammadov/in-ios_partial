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
    
    var startTotalTime: Double = 0.0
    var elapsedTotalTime: Double = 0.0
    
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
    func cm2pixels(gazeX: Double, gazeY: Double, camX: Double, camY: Double, orientation: UIDeviceOrientation) -> (gazeX: Double, gazeY: Double) {
        
        var gazeXFromCenter: Double = 0, gazeYFromCenter: Double = 0 //Distance of gaze from center in centimenters
        var pixelsX: Double = 0, pixelsY: Double = 0 //Distance of gaze from center in pixels
        
        switch orientation {
        case .portraitUpsideDown:
            gazeXFromCenter = gazeX - camX
            gazeYFromCenter = gazeY - camY
            pixelsX = Double(gazeXFromCenter * self.PPCM[0])// + self.screenWidthPix/2
            pixelsY = Double(gazeYFromCenter * self.PPCM[1])// + self.screenHeightPix/2
        case .landscapeLeft:
            gazeXFromCenter = gazeX - camY
            gazeYFromCenter = gazeY + camX
            pixelsX = Double(gazeXFromCenter * self.PPCM[1])// + self.screenHeightPix/2
            pixelsY = Double(gazeYFromCenter * self.PPCM[0])// + self.screenWidthPix/2
        case .landscapeRight:
            gazeXFromCenter = gazeX + camY
            gazeYFromCenter = gazeY - camX
            pixelsX = Double(gazeXFromCenter * self.PPCM[1])// + self.screenHeightPix/2
            pixelsY = Double(gazeYFromCenter * self.PPCM[0])// + self.screenWidthPix/2
        default:
            gazeXFromCenter = gazeX + camX
            gazeYFromCenter = gazeY + camY
            pixelsX = Double(gazeXFromCenter * self.PPCM[0])// + self.screenWidthPix/2
            pixelsY = Double(gazeYFromCenter * self.PPCM[1])// + self.screenHeightPix/2
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
        
        print("Algorithm starting @:      \(CFAbsoluteTimeGetCurrent())")
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
        
        DispatchQueue.global(qos: .background).async {
            self.startPrediction(scene: scene)
        }
    }
    
    public func didFindFaces(status: Bool, scene: UIImage) {
        print("Faces found @:             \(CFAbsoluteTimeGetCurrent())")
        
        if !status {
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        print("Getting main face @:       \(CFAbsoluteTimeGetCurrent())")
        getMainFace()
        
        let width = scene.cgImage!.width, height = scene.cgImage!.height
        
        print("Getting facial features @: \(CFAbsoluteTimeGetCurrent())")
        let facialFeatures: MLMultiArray = self.getFacialFeatures(width: width, height: height)
        print("Cropping eyes @:           \(CFAbsoluteTimeGetCurrent())")
        let eyes = self.getEyes(image: scene)
        guard let leftEye = eyes.leftEYe, let rightEye = eyes.rightEye else{
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        print("Concatenating eyes @:      \(CFAbsoluteTimeGetCurrent())")
        guard let eyesImage = self.concatenateEyes(leftEye: leftEye, rightEye: rightEye) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        print("Converting eyes @:         \(CFAbsoluteTimeGetCurrent())")
        guard let eyeChannels = self.channels2MLMultiArray(image: eyesImage) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        print("Estimating illuminant @:   \(CFAbsoluteTimeGetCurrent())")
        guard let illuminant = self.estimateIlluminant(image: scene) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        print("Estimating gaze @:         \(CFAbsoluteTimeGetCurrent())")
        let pred = self.predictGaze(eyesB: eyeChannels.blueChannel, eyesG: eyeChannels.greenChannel, eyesR: eyeChannels.redChannel, illuminant: illuminant, headPose: facialFeatures)
        
        self.gazeEstimation = pred
        print("Algorithm terminating @:   \(CFAbsoluteTimeGetCurrent())")
        self.predictionDelegate?.didUpdatePrediction(status: true)
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
    
    public func getFacialFeatures(width: Int, height: Int) -> MLMultiArray {
        //        TODO: Clean up code, deal with missing features more gracefully
        var featuresX: [Double] = Array(repeating: 0.0, count: 8)
        var featuresY: [Double] = Array(repeating: 0.0, count: 8)
        
        if let mouthBottom = self.mainFace?.landmark(ofType: .mouthBottom) {
            featuresX[0] = mouthBottom.position.x.doubleValue
            featuresY[0] = mouthBottom.position.y.doubleValue
        }
        
        if let mouthRight = self.mainFace?.landmark(ofType: .mouthRight) {
            featuresX[1] = mouthRight.position.x.doubleValue
            featuresY[1] = mouthRight.position.y.doubleValue
        }
        
        if let mouthLeft = self.mainFace?.landmark(ofType: .mouthLeft) {
            featuresX[2] = mouthLeft.position.x.doubleValue
            featuresY[2] = mouthLeft.position.y.doubleValue
        }
        
        if let earRight = self.mainFace?.landmark(ofType: .rightEar) {
            featuresX[3] = earRight.position.x.doubleValue
            featuresY[3] = earRight.position.y.doubleValue
        }
        
        if let earLeft = self.mainFace?.landmark(ofType: .leftEar) {
            featuresX[4] = earLeft.position.x.doubleValue
            featuresY[4] = earLeft.position.y.doubleValue
        }
        
        if let cheekRight = self.mainFace?.landmark(ofType: .rightCheek) {
            featuresX[5] = cheekRight.position.x.doubleValue
            featuresY[5] = cheekRight.position.y.doubleValue
        }
        
        if let cheekLeft = self.mainFace?.landmark(ofType: .leftCheek) {
            featuresX[6] = cheekLeft.position.x.doubleValue
            featuresY[6] = cheekLeft.position.y.doubleValue
        }
        
        if let nose = self.mainFace?.landmark(ofType: .noseBase) {
            featuresX[7] = nose.position.x.doubleValue
            featuresY[7] = nose.position.y.doubleValue
        }
        
        guard let mlFeatures = try? MLMultiArray(shape:[16], dataType:MLMultiArrayDataType.double) else {
                fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        for i in 0...7 {
            mlFeatures[2*i] = (featuresX[i]/Double(width)) as NSNumber
            mlFeatures[2*i + 1] = (featuresY[i]/Double(height)) as NSNumber
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
        
        let cropLen: Int = Int(1.3*abs((rightEyePos?.x.floatValue)! - (leftEyePos?.x.floatValue)!)/2 * Float(image.scale))
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
     */
    private func channels2MLMultiArray(image: CGImage) -> (redChannel: MLMultiArray, greenChannel: MLMultiArray, blueChannel: MLMultiArray)? {
        
        let width = image.width
        let height = image.height
        let stride = image.bytesPerRow
        
        
        guard let redChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard let greenChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard let blueChannel = try? MLMultiArray(shape: [1, height as NSNumber, width as NSNumber], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        var step: Int = 3, rOff: Int = 0, gOff: Int = 1, bOff: Int = 2
        switch image.alphaInfo {
        case .alphaOnly:
            return nil
        case .none, .noneSkipLast, .noneSkipFirst:
            break
        case .last, .premultipliedLast:
            step = 4
        case .first, .premultipliedFirst:
            step = 4; rOff = 1; gOff = 2; bOff = 3;
        }
        
        let provider = image.dataProvider
        let providerData = provider?.data
        guard let data = CFDataGetBytePtr(providerData) else { return nil }
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y*stride + x*step
                let red: Double = Double(data[offset+rOff])/255.0
                let green: Double = Double(data[offset+gOff])/255.0
                let blue: Double = Double(data[offset+bOff])/255.0

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
        guard let illuminant = try? MLMultiArray(shape: [3], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for i in 0...2 {
            illuminant[i] = 1.0 as NSNumber
        }
        return illuminant
        
        guard
            let cgImage = image.cgImage,
            let sourceColorSpace = cgImage.colorSpace else { return nil }
        
        let width = Int(Double(cgImage.width) * self.illumResizeRatio)
        let height = Int(Double(cgImage.height) * self.illumResizeRatio)
        let stride = cgImage.bytesPerRow/cgImage.width * width
        let count = width*height
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: stride,
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
        
        var L: [Float] = Array<Float>(repeating: 0.0, count: count)
        
        var redLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        var greenLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        var blueLog: [Float] = Array<Float>(repeating: 0.0, count: count)
        
        var step: Int = 3, rOff: Int = 0, gOff: Int = 1, bOff: Int = 2
        switch cgImage.alphaInfo {
        case .alphaOnly:
            return nil
        case .none, .noneSkipLast, .noneSkipFirst:
            break
        case .last, .premultipliedLast:
            step = 4
        case .first, .premultipliedFirst:
            step = 4; rOff = 1; gOff = 2; bOff = 3;
        }
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y*stride + x*step
                let index = y * width + x
                
                let red = Float(data[offset + rOff])/255.0 + 1e-50
                let green = Float(data[offset + gOff])/255.0 + 1e-50
                let blue = Float(data[offset + bOff])/255.0 + 1e-50
                
                redChannel[index] = red
                greenChannel[index] = green
                blueChannel[index] = blue
                L[index] = [red, green, blue].reduce(0, +)/3.0
                redLog[index] = Darwin.log(red)
                greenLog[index] = Darwin.log(green)
                blueLog[index] = Darwin.log(blue)
            }
        }
        var normImage: [[Float]] = [redChannel, greenChannel, blueChannel]
        let logImage: [[Float]] = [redLog, greenLog, blueLog]
        
        //Apply edge detection (Laplace) to each color channel of the log-space image. Store in variable (SDN)
        let width2 = width-1, height2 = height-1
        let count2 = width2 * height2
        var SDN: [[Float]] = [Array(repeating: 0.0, count: count2), Array(repeating: 0.0, count: count2), Array(repeating: 0.0, count: count2)]
        
        let kernelPrt: UnsafePointer<Float> = UnsafePointer<Float>(LAPLACE_OPERATOR)
        for (i, logChannel) in logImage.enumerated() {
            let channelPtr: UnsafePointer<Float> = UnsafePointer<Float>(logChannel)
            let sdnPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: logChannel.count)
            sdnPointer.initialize(repeating: 0.0, count: logChannel.count)
            
            Accelerate.vDSP_f3x3(channelPtr, vDSP_Length(height), vDSP_Length(width), kernelPrt, sdnPointer)
            for y in 0..<height2 {
                for x in 0..<width2 {
                    SDN[i][y*width2 + x] = abs(sdnPointer[(y+1)*width + x+1])
                }
            }
            sdnPointer.deallocate()
        }
        
        //Average SDN over the color channels. Store in variable (aSDN)
        var aSDN: [Float] = Array(repeating: 0.0, count: count2)
        for i in 0..<count2 {
            aSDN.append([SDN[0][i], SDN[1][i], SDN[2][i]].reduce(0, +)/3.0)
        }
        
        //Compute constant P
        var P: [Float] = Array<Float>(repeating: 0.0, count: count2)
        for i in 0..<count2 {
            let innerSum: [Float] = [pow(SDN[0][i] - aSDN[i], 2.0)/aSDN[i],
                                     pow(SDN[1][i] - aSDN[i], 2.0)/aSDN[i],
                                     pow(SDN[2][i] - aSDN[i], 2.0)/aSDN[i]]
            P[i] = sqrtf(innerSum.reduce(0, +)/3.0)
        }
        
        //Compute EGI from constants P and L. Store in variable.
        var temp: [Float] = Array<Float>(repeating: 0.0, count: count2)
        for y in 0..<height2 {
            for x in 0..<width2 {
                temp[y*width2 + x] = P[y*width2 + x]/L[(y+1)*width + x+1]
            }
        }
        
        let filtPtr: UnsafePointer<Float> = UnsafePointer<Float>(AVERAGING_FILTER)
        let tempPtr: UnsafePointer<Float> = UnsafePointer<Float>(temp)
        let egiPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: count)
        egiPointer.initialize(repeating: 0.0, count: count)
        Accelerate.vDSP_imgfir(tempPtr, vDSP_Length(height2), vDSP_Length(width2), filtPtr, egiPointer, 7, 7)
        
        let width3 = width2-3, height3 = height2-3
        let count3 = width3*height3
        var EGI: [Float] = Array(repeating: 0.0, count: count3)
        for y in 0..<height3 {
            for x in 0..<width3 {
                EGI[y*width3 + x] = egiPointer[(y+3)*width2 + x+3]
            }
        }
        egiPointer.deallocate()
        
        //Compute GPn
        let nGrey: Int = Int(0.1 * Float(count3))
        let threshold: Float = EGI.sorted {$0 > $1}[nGrey]
        var GPn: [Int] = []
        for (index, val) in EGI.enumerated() {
            if val < threshold {
                let x = index%width3, y = index/width3
                GPn.append((y+4)*width + x+4)
            }
        }
        
        //Compute the illuminant values
        var e_i: [Float] = Array<Float>(repeating: 1.0, count: 3)
        for i in 0...2 {
            var channelGreys: [Float] = Array<Float>(repeating: 0.0, count: GPn.count)
            for (j, index) in GPn.enumerated() { channelGreys[j] = normImage[i][index] }
            e_i[i] = channelGreys.reduce(0, +)/Float(nGrey)
        }
        
        e_i = e_i.map {$0/e_i.max()!}
        
        //Populate it and return it
        for i in 0...2 {
            illuminant[i] = e_i[i].isNaN ? 1.0 : e_i[i] as NSNumber
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

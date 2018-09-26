//
//  FaceFinder.swift
//  INGazeTracking
//
//  Created by Alexandre Drouin-Picaro on 2018-08-10.
//  Copyright © 2018 innodem-neurosciences. All rights reserved.
//

import Foundation
import Firebase

class FaceFinder {
    
    let RESIZE: Float = 0.5
    
    var faces: [VisionFace]? = nil
    var detector: VisionFaceDetector? = nil
    var delegate: FaceFinderDelegate? = nil
    
    init() {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        setupGMVFaceDetectorForPhoto()
    }
    
    /**
     Setup the face detector
     */
    private func setupGMVFaceDetectorForPhoto() {
        let options = VisionFaceDetectorOptions()
        options.landmarkType = .all
        options.classificationType = .all
        options.isTrackingEnabled = true
        
        let vision = Vision.vision()
        self.detector = vision.faceDetector(options: options)
    }
    
    public func getFaces(scene: UIImage) {
        
//        print("\(scene.size)")
        print("Face detection start @:    \(CFAbsoluteTimeGetCurrent())")
        let visionImage = VisionImage(image: scene)
        if let detector = self.detector {
            detector.detect(in: visionImage) { [weak self] (faces, error) in
                guard let strongSelf = self else { return }
                guard error == nil, let faces = faces, !faces.isEmpty else {
                    strongSelf.faces = nil
                    print("No face detected")
                    strongSelf.didFindFaces(status: false, scene: scene)
                    return
                }
                strongSelf.faces = faces
                strongSelf.didFindFaces(status: true, scene: scene)
            }
        } else {
            print("Face detector is nil")
        }
    }
    
    public func didFindFaces(status: Bool, scene: UIImage) {
        print("Calling delegate     @:    \(CFAbsoluteTimeGetCurrent())")
        self.delegate?.didFindFaces(status: status, scene: scene)
    }
    
    private func resizeImage(image: UIImage, factor: Float) -> UIImage? {
        guard let cgImage: CGImage = image.cgImage else {return nil}
        guard let colorspace = cgImage.colorSpace else {return nil}
        
        let width: Int = Int(Float(cgImage.width) * factor)
        let height: Int = Int(Float(cgImage.height) * factor)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: width*cgImage.bitsPerPixel/8,
                                      space: colorspace,
                                      bitmapInfo: cgImage.alphaInfo.rawValue) else {return nil}
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let newImage = context.makeImage() else {return nil}
        return UIImage(cgImage: newImage)
    }
}

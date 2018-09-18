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
        
        let vision = Vision.vision()
        self.detector = vision.faceDetector(options: options)
    }
    
    public func getFaces(scene: UIImage) {
        
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
        self.delegate?.didFindFaces(status: status, scene: scene)
    }
}

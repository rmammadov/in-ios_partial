//
//  GazeTrackerCalibrated.swift
//  in-ios
//
//  Created by Alexandre Drouin-Picaro on 2018-10-04.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import CoreML
import UIKit

class GazeTrackerCalibrated: GazeTracker {
    
    var calibModel: MLModel? = nil
    
    init(delegate: GazePredictionDelegate?, illumResizeRatio: Double = 1.0, modelURL: URL) {
        super.init(delegate: delegate, illumResizeRatio: illumResizeRatio)
    }
    
    func loadModel(at modelURL: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: modelURL.absoluteString) {
            do {
                self.calibModel = try MLModel(contentsOf: modelURL)
            } catch {
                print("Failed to load model")
            }
        } else {
            do {
                let compiledURL = try MLModel.compileModel(at: modelURL)
                self.calibModel = try MLModel(contentsOf: compiledURL)
                saveModelToFile(saveURL: compiledURL)
            } catch {
                print("Failed to load model")
            }
        }
    }
    
    func saveModelToFile(saveURL: URL) {
        let fileManager = FileManager.default
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask, appropriateFor: saveURL, create: true)
        // create a permanent URL in the app support directory
        let permanentUrl = appSupportDirectory.appendingPathComponent(saveURL.lastPathComponent)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.absoluteString) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: saveURL)
            } else {
                try fileManager.copyItem(at: saveURL, to: permanentUrl)
            }
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
    }
    
    override public func didFindFaces(status: Bool, scene: UIImage) {
        if !status {
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        getMainFace()
        
        let width = scene.cgImage!.width, height = scene.cgImage!.height
        let facialFeatures: MLMultiArray = self.getFacialFeatures(width: width, height: height)
        let eyes = self.getEyes(image: scene)
        guard let leftEye = eyes.leftEYe, let rightEye = eyes.rightEye else{
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        guard let eyesImage = self.concatenateEyes(leftEye: leftEye, rightEye: rightEye) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        guard let eyeChannels = self.channels2MLMultiArray(image: eyesImage) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        guard let illuminant = self.estimateIlluminant(image: scene) else {
            self.gazeEstimation = nil
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        guard let pred = predictGaze(eyesB: eyeChannels.blueChannel, eyesG: eyeChannels.greenChannel, eyesR: eyeChannels.redChannel, illuminant: illuminant, headPose: facialFeatures) else {
            self.gazeEstimation = nil
            self.calibFeatures = nil
            return
        }
        
        //TODO: Feed the prediction to the calibrated model
        
        self.gazeEstimation = pred.gazeXY
        self.elapsedTotalTime = CFAbsoluteTimeGetCurrent() - self.startTotalTime
        print("\nTotal algorithm processing time: \(self.elapsedTotalTime) s.")
        if pred != nil { print(self.gazeEstimation![0], self.gazeEstimation![1]) }
        self.predictionDelegate?.didUpdatePrediction(status: true)
    }
    
}

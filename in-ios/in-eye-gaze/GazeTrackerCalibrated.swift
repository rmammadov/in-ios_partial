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

class CalibrationInput: MLFeatureProvider {
    
    var input: Double
    var featureNames: Set<String> = ["inputFeatures"]
    
    init(input: Double) {
        self.input = input
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "inputFeatures" {
            return MLFeatureValue(double: input)
        }
        return nil
    }
    
    
}

class GazeTrackerCalibrated: GazeTracker {
    
    var PERMANENT_URL_CALIBRATION_X: URL
    var PERMANENT_URL_CALIBRATION_Y: URL
    let SAVE_DIRECTORY = "Calibration Models"
    let fileManager = FileManager.default
    
    var calibModelX: MLModel? = nil
    var calibModelY: MLModel? = nil
    
    init(delegate: GazePredictionDelegate?, illumResizeRatio: Double = 1.0, xModelURL: URL, yModelURL: URL) {
        
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let modelSaveDirectory: URL = appSupportDirectory.appendingPathComponent("Calibration Models", isDirectory: true)
        PERMANENT_URL_CALIBRATION_X = modelSaveDirectory.appendingPathComponent("CalibrationX.mlmodelc")
        PERMANENT_URL_CALIBRATION_Y = modelSaveDirectory.appendingPathComponent("CalibrationY.mlmodelc")
        
        super.init(delegate: delegate, illumResizeRatio: illumResizeRatio)
        
        try! fileManager.createDirectory(at: modelSaveDirectory, withIntermediateDirectories: true, attributes: nil)
        if fileManager.fileExists(atPath: PERMANENT_URL_CALIBRATION_X.absoluteString) {
            do {
                self.calibModelX = try MLModel(contentsOf: PERMANENT_URL_CALIBRATION_X)
            } catch {
                print("Failed to load stored compiled CalibrationX model.")
            }
        }
        
        if fileManager.fileExists(atPath: PERMANENT_URL_CALIBRATION_Y.absoluteString) {
            do {
                self.calibModelY = try MLModel(contentsOf: PERMANENT_URL_CALIBRATION_Y)
            } catch {
                
            }
        }
    }
    
    func loadModels(xModelURL: URL, yModelURL: URL) {
        do {
            let compiledURL = try MLModel.compileModel(at: xModelURL)
            self.calibModelX = try MLModel(contentsOf: compiledURL)
            saveModelToFile(compiledModelURL: compiledURL, isXModel: true)
        } catch {
            print("Failed to load CalibrationX model")
        }
        
        do {
            let compiledURL = try MLModel.compileModel(at: yModelURL)
            self.calibModelY = try MLModel(contentsOf: compiledURL)
            saveModelToFile(compiledModelURL: compiledURL, isXModel: false)
        } catch {
            print("Failed to load CalibrationY model.")
        }
    }
    
    func saveModelToFile(compiledModelURL: URL, isXModel: Bool) {
        do {
            if isXModel {
                if fileManager.fileExists(atPath: PERMANENT_URL_CALIBRATION_X.absoluteString) {
                    _ = try fileManager.replaceItemAt(PERMANENT_URL_CALIBRATION_X, withItemAt: compiledModelURL)
                } else {
                    try fileManager.copyItem(at: compiledModelURL, to: PERMANENT_URL_CALIBRATION_X)
                }
            } else {
                if fileManager.fileExists(atPath: PERMANENT_URL_CALIBRATION_Y.absoluteString) {
                    _ = try fileManager.replaceItemAt(PERMANENT_URL_CALIBRATION_Y, withItemAt: compiledModelURL)
                } else {
                    try fileManager.copyItem(at: compiledModelURL, to: PERMANENT_URL_CALIBRATION_Y)
                }
            }
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
    }
    
    override func didFindFaces(status: Bool, scene: UIImage) {
        if !status {
            self.predictionDelegate?.didUpdatePrediction(status: false)
            return
        }
        
        getMainFace()
        
        let width = scene.cgImage!.width, height = scene.cgImage!.height
        let facialFeatures: MLMultiArray = self.getFacialFeatures(width: width, height: height)
        let eyes = self.getEyes(image: scene)
        guard let leftEye = eyes.leftEYe, let rightEye = eyes.rightEye else {
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
        
        if let calibFeats = pred.gazeXY {
            do {
                let predX = try self.calibModelX?.prediction(from: CalibrationInput(input: Double(truncating: calibFeats[0])))
                let predY = try self.calibModelY?.prediction(from: CalibrationInput(input: Double(truncating: calibFeats[1])))
                
                self.gazeEstimation = [predX!.featureValue(for: "gazeXY")!.doubleValue as NSNumber,
                                       predY!.featureValue(for: "gazeXY")!.doubleValue as NSNumber]
                self.elapsedTotalTime = CFAbsoluteTimeGetCurrent() - self.startTotalTime
                print("\nTotal calibrated algorithm processing time: \(self.elapsedTotalTime) s.")
                print("General model predictions: \(calibFeats[0]), \(calibFeats[1])")
                if self.gazeEstimation != nil { print("Calibrated model predictions: \(self.gazeEstimation![0]), \(self.gazeEstimation![1])") }
                self.predictionDelegate?.didUpdatePrediction(status: true)
            } catch {
                self.gazeEstimation = nil
                self.calibFeatures = nil
                return
            }
        } else {
            self.gazeEstimation = nil
            self.calibFeatures = nil
            return
        }
    }
    
}

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
    
    let SAVE_DIRECTORY = "Calibration Models"
    let fileManager = FileManager.default
    let rootSaveDirectory: URL
    
    static let MODEL_MAPPING_X: String = "ModelX"
    static let MODEL_MAPPING_Y: String = "ModelY"
    let X_COMPILED_FILE_NAME: String = "CalibrationX.mlmodelc"
    let Y_COMPILED_FILE_NAME: String = "CalibrationY.mlmodelc"
    
    let directoryMappings: [UIDeviceOrientation: String] = [UIDeviceOrientation.portrait: "Portrait",
                                                            UIDeviceOrientation.portraitUpsideDown: "Portrait Upsaide Down",
                                                            UIDeviceOrientation.landscapeLeft: "Landscape Left",
                                                            UIDeviceOrientation.landscapeRight: "Landscape Right"]
    var modelMappings: [UIDeviceOrientation: [String: MLModel?]] = [UIDeviceOrientation.portrait: [MODEL_MAPPING_X: nil, MODEL_MAPPING_Y: nil],
                                                                     UIDeviceOrientation.portraitUpsideDown: [MODEL_MAPPING_X: nil, MODEL_MAPPING_Y: nil],
                                                                     UIDeviceOrientation.landscapeLeft: [MODEL_MAPPING_X: nil, MODEL_MAPPING_Y: nil],
                                                                     UIDeviceOrientation.landscapeRight: [MODEL_MAPPING_X: nil, MODEL_MAPPING_Y: nil]]
    
    var calibModelX: MLModel? = nil
    var calibModelY: MLModel? = nil
    
    override init(delegate: GazePredictionDelegate?, illumResizeRatio: Double = 1.0) {
        
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        rootSaveDirectory = appSupportDirectory.appendingPathComponent(SAVE_DIRECTORY, isDirectory: true)
        super.init(delegate: delegate, illumResizeRatio: illumResizeRatio)
        
        //Check if save directory exists. If not, create it and its subfolders, and return since no calibration models can be present on the device
        var isDir = ObjCBool(true)
        if !fileManager.fileExists(atPath: rootSaveDirectory.absoluteString, isDirectory: &isDir) {
            try! fileManager.createDirectory(at: rootSaveDirectory, withIntermediateDirectories: true, attributes: nil)
            for (_, folder) in self.directoryMappings {
                let subfolder = rootSaveDirectory.appendingPathComponent(folder, isDirectory: true)
                try! fileManager.createDirectory(at: subfolder, withIntermediateDirectories: true, attributes: nil)
            }
            return
        }
        
        //Load orientation-specific models
        for (orientation, folder) in self.directoryMappings {
            let modelXPath: URL = rootSaveDirectory.appendingPathComponent(folder, isDirectory: true).appendingPathComponent(X_COMPILED_FILE_NAME)
            let modelYPath: URL = rootSaveDirectory.appendingPathComponent(folder, isDirectory: true).appendingPathComponent(Y_COMPILED_FILE_NAME)
            
            if fileManager.fileExists(atPath: modelXPath.absoluteString), fileManager.fileExists(atPath: modelYPath.absoluteString) {
                do {
                    self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_X] = try MLModel(contentsOf: modelXPath)
                    self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_Y] = try MLModel(contentsOf: modelYPath)
                } catch {
                    self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_X] = nil
                    self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_Y] = nil
                    print("Failed to load models for device orientation: \(orientation)")
                }
            } else {
                self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_X] = nil
                self.modelMappings[orientation]![GazeTrackerCalibrated.MODEL_MAPPING_Y] = nil
            }
        }
        
        //Assign proper models, based on current orientation, to the models to be used for inference.
//        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
//        switch deviceOrientation {
//        case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
//            calibModelX = self.modelMappings[deviceOrientation]![GazeTrackerCalibrated.MODEL_MAPPING_X]!
//            calibModelY = self.modelMappings[deviceOrientation]![GazeTrackerCalibrated.MODEL_MAPPING_Y]!
//        default:
//            break
//        }
    }
    
    /**
     Updates the current models to the ones corresponding to the new device orientation.
     
     - parameter newOrientation: The new (current) orientation of the device.
     - Returns: true if the new orientation exists in the orientation-to-model mapping dictionary and the corresponding models also exist. Else, returns false.
     */
    func setOrientation(to newOrientation: UIDeviceOrientation) -> Bool{
        guard let mapping = modelMappings[newOrientation] else {
            self.calibModelX = nil
            self.calibModelY = nil
            return false
        }
        guard let modelX = mapping[GazeTrackerCalibrated.MODEL_MAPPING_X], let modelY = mapping[GazeTrackerCalibrated.MODEL_MAPPING_Y] else {
            self.calibModelX = nil
            self.calibModelY = nil
            return false
        }
        if let modelX = modelX, let modelY = modelY {
            self.calibModelX = modelX
            self.calibModelY = modelY
            return true
        } else {
            self.calibModelX = nil
            self.calibModelY = nil
            return false
        }
    }
    
    /**
     Compiles the .mlmodel files and saves them to permanent storage. Also updates the dictionary of available models.
     
     - parameter xModelURL: The URL to the .mlmodel file that represents the calibration model for the horizontal dimension.
     - parameter yModelURL: The URL to the .mlmodel file that represents the calibration model for the vertical dimension.
     - parameter orientation: The orientation of the device at the time of calibration. Can be retrived from the JSON file generated by the calibration, the same JSON file that was used to train the calibration models.
     
     - returns: True if the models could be loaded, compiled and saved. Else, returns false.
     */
    func updateWithNewModels(xModelURL: URL, yModelURL: URL, orientation: UIDeviceOrientation) -> Bool {
        switch orientation {
        case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
            do {
                let compiledXURL = try MLModel.compileModel(at: xModelURL)
                let compiledYURL = try MLModel.compileModel(at: yModelURL)
                let modelX = try MLModel(contentsOf: compiledXURL)
                let modelY = try MLModel(contentsOf: compiledYURL)
                
                // Assign models to the proper variables
                self.calibModelX = modelX
                self.calibModelY = modelY
                self.modelMappings[orientation] = [GazeTrackerCalibrated.MODEL_MAPPING_X: modelX, GazeTrackerCalibrated.MODEL_MAPPING_Y: modelY]
                
                //Build save path and save models
                let saveDirectoryPath: URL = self.rootSaveDirectory.appendingPathComponent(self.directoryMappings[orientation]!)
                let xModelSavePath: URL = saveDirectoryPath.appendingPathComponent(X_COMPILED_FILE_NAME)
                let yModelSavePath: URL = saveDirectoryPath.appendingPathComponent(Y_COMPILED_FILE_NAME)
                
                if saveModelToFile(compiledModelURL: compiledXURL, destinationURL: xModelSavePath), saveModelToFile(compiledModelURL: compiledYURL, destinationURL: yModelSavePath) {
                    return true
                } else {
                    return false
                }
                
            } catch {
                print("Failed to load calibration models")
                return false
            }
        default:
            print("The supplied orientation did not match any of the supported device orientations.")
            return false
        }
    }
    
    /**
     Saves a compiled mlmodel file to permanent storage.
     
     - parameter compiledModelURL: The URL to the .mlmodelc file
     - parameter destinationURL: The path to which the model should be saved. If this file already exists, IT WILL BE OVERWRITTEN.
     
     - returns: True if the operation is successful, else false.
     */
    func saveModelToFile(compiledModelURL: URL, destinationURL: URL) -> Bool {
        do {
            if fileManager.fileExists(atPath: destinationURL.absoluteString) {
                _ = try fileManager.replaceItemAt(destinationURL, withItemAt: compiledModelURL)
            } else {
                try fileManager.copyItem(at: compiledModelURL, to: destinationURL)
            }
            return true
        } catch {
            print("Error during copy: \(error.localizedDescription)")
            return false
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

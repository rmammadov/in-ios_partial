//
//  LandscapeRightGazeEstimator.swift
//  in-ios
//
//  Created by Alexandre Drouin-Picaro on 2018-11-26.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import CoreML

class LandscapeRightGazeEstimator: GazeEstimatorProtocol {
    var predictionOptions: MLPredictionOptions = MLPredictionOptions()
    
    let horizontalModel = LandscapeRightModelHorizontal()
    let verticalModel = LandscapeRightModelVertical()
    
    init() {
        self.predictionOptions.usesCPUOnly = true
    }
    
    func predictGaze(eyesB: MLMultiArray, eyesG: MLMultiArray, eyesR: MLMultiArray, illuminant: MLMultiArray, headPose: MLMultiArray) -> (gazeXY: Array<NSNumber>?, calibFeats: MLMultiArray?)? {
        
        do {
            let horizontalOutput = try horizontalModel.prediction(input: LandscapeRightModelHorizontalInput(eyesB: eyesB, eyesG: eyesG, eyesR: eyesR, illum: illuminant, pose: headPose), options: self.predictionOptions)
            let verticalOutput = try verticalModel.prediction(input: LandscapeRightModelVerticalInput(eyesB: eyesB, eyesG: eyesG, eyesR: eyesR, illum: illuminant, pose: headPose), options: self.predictionOptions)
            let prediction = [horizontalOutput.gazeXY[0] as NSNumber,
                              verticalOutput.gazeXY[0] as NSNumber]
            print("Generated prediction for landscape right orientation.")
            return (prediction, verticalOutput.calibFeats)
        } catch {
            print(error)
            return nil
        }
    }
}

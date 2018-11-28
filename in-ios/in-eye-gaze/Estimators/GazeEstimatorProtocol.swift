//
//  GazeEstimatorProtocol.swift
//  in-ios
//
//  Created by Alexandre Drouin-Picaro on 2018-11-26.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import CoreML

protocol GazeEstimatorProtocol {
    var predictionOptions: MLPredictionOptions { get set }
    
    func predictGaze(eyesB: MLMultiArray, eyesG: MLMultiArray, eyesR: MLMultiArray, illuminant: MLMultiArray, headPose: MLMultiArray) -> (gazeXY: Array<NSNumber>?, calibFeats: MLMultiArray?)?
}

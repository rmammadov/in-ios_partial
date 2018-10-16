//
//  IntroThirdNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import UIKit

enum CalibrationStep: Int {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    case fifth = 5
}

class IntroThirdNewModel: BaseModel {
    
    private var calibrationStep: Int = CalibrationStep.first.rawValue
    private var index = 0
    private var tagsCalibrationFirstStep: Array = Constant.CalibrationConfig.CALIBRATION_TAGS_FIRST_STEP
    private var tagsCalibrationSecondStep: Array = Constant.CalibrationConfig.CALIBRATION_TAGS_SECOND_STEP
    
    func getTag() -> Int {
        let tags = getTags()
        var tag: Int?
        if index < tags.count {
            tag = tags[index]
            index += 1
        } else {
            tag = 0
            index = 0
        }
        return tag!
    }
    
    func getTags() -> Array<Int> {
        if calibrationStep == CalibrationStep.third.rawValue {
            return tagsCalibrationSecondStep
        } else {
            return tagsCalibrationFirstStep
        }
    }
    
    func setCalibrationStep(step: Int) {
        calibrationStep = step
    }
    
    func getCalibrationStep() -> Int {
        return calibrationStep
    }
    
    func setCalibrationData(image: UIImage, data: CalibrationData) {
        DataManager.setCalibrationDataFor(image: image, data: data)
    }
    
    func postProfileData() {
        DataManager.postProfileData()
    }
}

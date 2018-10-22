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
    
    func nextStep() {
        if calibrationStep < CalibrationStep.fifth.rawValue {
            calibrationStep += 1
        }
    }
    
    func previousStep() {
        if calibrationStep > CalibrationStep.first.rawValue {
            calibrationStep -= 1
        }
    }
    
    func getTag() -> Int {
        let tags = getTags()
        var tag: Int?
        
        if index < getMaxIndex() {
            tag = tags[index]
            index += 1
        } else {
            tag = 0
            index = 0
        }
        return tag!
    }
    
    func getNextTag() -> Int {
        return getTags()[index]
    }
    
    func getTags() -> Array<Int> {
        if calibrationStep == CalibrationStep.third.rawValue {
            return tagsCalibrationSecondStep
        } else {
            return tagsCalibrationFirstStep
        }
    }
    
    func getMaxIndex() -> Int {
        if calibrationStep == CalibrationStep.third.rawValue {
            return getTags().count - 1
        } else {
            return getTags().count
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

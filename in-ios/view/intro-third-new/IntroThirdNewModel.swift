//
//  IntroThirdNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum CalibrationStatus: Int {
    case firstStep = 1
    case secondStep = 2
    case thirdStep = 3
    case fourthStep = 4
    case fifthStep = 5
    case noInternetConnection = 6
}

class IntroThirdNewModel: BaseModel {
    
    var status = Variable<Int>(0)
    
    private var calibrationStep: Int = CalibrationStatus.firstStep.rawValue
    private var index = 0
    private var tagsCalibrationFirstStep: Array = Constant.CalibrationConfig.CALIBRATION_TAGS_FIRST_STEP
    private var tagsCalibrationSecondStep: Array = Constant.CalibrationConfig.CALIBRATION_TAGS_SECOND_STEP
    
    func nextStep() {
        if calibrationStep < CalibrationStatus.fifthStep.rawValue {
            calibrationStep += 1
        }
    }
    
    func previousStep() {
        if calibrationStep > CalibrationStatus.firstStep.rawValue {
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
        if calibrationStep == CalibrationStatus.thirdStep.rawValue {
            return tagsCalibrationSecondStep
        } else {
            return tagsCalibrationFirstStep
        }
    }
    
    func getMaxIndex() -> Int {
        if calibrationStep == CalibrationStatus.thirdStep.rawValue {
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
        if ReachabilityManager.shared.isNetworkAvailable {
            DataManager.setCalibrationDataFor(image: image, data: data)
        } else {
            
        }
    }
    
    func postProfileData() {
        if ReachabilityManager.shared.isNetworkAvailable {
            DataManager.postProfileData()
        } else {
            
        }
    }
}

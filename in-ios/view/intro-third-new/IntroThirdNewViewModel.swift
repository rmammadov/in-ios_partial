//
//  IntroThirdNewViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroThirdNewViewModel: BaseViewModel {
    
    private let model: IntroThirdNewModel = IntroThirdNewModel()
    
    func nextStep() {
        model.nextStep()
    }
    
    func previousStep() {
        model.previousStep()
    }
    
    func getTag() -> Int {
        return model.getTag()
    }
    
    func getAnimationType() -> Int {
        return model.getAnimationType()
    }
    
    func setCalibrationData(image: UIImage, data: CalibrationData) {
        model.setCalibrationData(image: image, data: data)
    }
    
    func setCalibrationStep(step: Int) {
        model.setCalibrationStep(step: step)
    }
    
    func getCalibrationStep() -> Int {
        return model.getCalibrationStep()
    }
    
    func postProfileData() {
        model.postProfileData()
    }
}


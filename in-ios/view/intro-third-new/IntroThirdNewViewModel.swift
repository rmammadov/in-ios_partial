//
//  IntroThirdNewViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class IntroThirdNewViewModel: BaseViewModel {
    
    var status = Variable<Int>(0)
    
    let disposeBag = DisposeBag()
    
    private let model: IntroThirdNewModel = IntroThirdNewModel()
    
    func setSubscribers() {
        
    }
    
    func nextStep() {
        model.nextStep()
    }
    
    func previousStep() {
        model.previousStep()
    }
    
    func getTag() -> Int {
        return model.getTag()
    }
    
    func getNextTag() -> Int {
        return model.getNextTag()
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


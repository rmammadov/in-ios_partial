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
        model.setSubscribers()
        model.status.asObservable().subscribe(onNext: {
            event in
            if self.model.status.value == CalibrationStatus.loadingCalibrationCompleted.rawValue {
                self.status.value = CalibrationStatus.loadingCalibrationCompleted.rawValue
            }
        }).disposed(by: disposeBag)
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
    
    func setCalibrationStep(step: Int) {
        model.setCalibrationStep(step: step)
    }
    
    func getCalibrationStep() -> Int {
        return model.getCalibrationStep()
    }

    func getXModelUrl() -> String? {
        return model.getXModelUrl()
    }
    
    func getYModelUrl() -> String? {
        return model.getYModelUrl()
    }
    
    func getOreintation() -> String? {
        return model.getOrientation()
    }
    
    func getCalibrationOrientation() -> String? {
        return model.getCalibrationOrientation()
    }
    
    func setCalibrationDataFor(image: UIImage, data: CalibrationData) {
        model.setCalibrationDataFor(image: image, data: data)
    }
    
    func postProfileData() {
        model.postProfileData()
    }
}


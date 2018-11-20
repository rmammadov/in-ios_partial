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
    case processingStep = 8
    case fourthStep = 4
    case fifthStep = 5
    case loadingCalibrationCompleted = 6
    case noInternetConnection = 7
}

class IntroThirdNewModel: BaseModel {
    
    var status = Variable<Int>(0)
    
    let disposeBag = DisposeBag()
    
    private var calibrationStep: Int = CalibrationStatus.firstStep.rawValue
    private var index = 0
    private var tagsCalibrationSteps = Constant.CalibrationConfig.CALIBRATION_TAGS_STEPS
    private var calibrationData: Calibration?
    
    private let apiHelper = CalibrationApiHelper()
    weak var delegate: CalibrationRequestDelegate? {
        didSet {
            apiHelper.delegate = delegate
        }
    }
    
    func setSubscribers() {
        DataManager.status.asObservable().subscribe(onNext: {
            event in
            if DataManager.status.value == DataStatus.loadingModelCompleted.rawValue {
                self.status.value = CalibrationStatus.loadingCalibrationCompleted.rawValue
            }
        }).disposed(by: disposeBag)
    }
    
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
        return tagsCalibrationSteps
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
    
    func getCalibrationOrientation() -> String? {
        return apiHelper.getCalibrationOrientation()
    }
    
    func setCalibrationDataFor(image: UIImage, data: CalibrationData) {
        apiHelper.setCalibrationDataFor(image: image, data: data)
    }
    
    func postProfileData() {
        apiHelper.preparePostProfileOperation()
    }
    
    func getXModelUrl() -> String? {
        return DataManager.getXModelUrl()
    }
    
    func getYModelUrl() -> String? {
        return DataManager.getYModelUrl()
    }
    
    func getOrientation() -> String? {
        return DataManager.getOrientation()
    }
}

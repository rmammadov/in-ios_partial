//
//  IntroSecondNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

enum IntroSecondNewModelStatus: Int {
    case userName = 0
    case loaded = 1
}

class IntroSecondNewModel: BaseModel {
    
    var status = Variable<Int>(0)
    
    private var name: String = ""
    private var gender: String = Constant.DefaultValues.GEDNER_OPTIONS[0]
    private var ageGroup: String = Constant.DefaultValues.AGE_GROUPS[0]
    private var medicalCondition: String = Constant.DefaultValues.MEDICAL_CONDITIONS[0]
    private let validator: InputValidationHelper = InputValidationHelper()
    
    func getGenderOptions() -> Array<String> {
        return Constant.DefaultValues.GEDNER_OPTIONS
    }
    
    func getAgeGroups() -> Array<String> {
        return Constant.DefaultValues.AGE_GROUPS
    }
    
    func getMedicalConditions() -> Array<String> {
        return Constant.DefaultValues.MEDICAL_CONDITIONS
    }
    
    func setName(name: String?) {
        guard let name = name else { return }
        self.name = name
    }
    
    func getName() -> (name: String, isValid: Bool) {
        let isValid = validator.isValidInput(Input: name, regEx: Constant.InputValidationConfig.REGEX_NAME)
        return (name: name, isValid: isValid)
    }
    
    func setGender(index: Int?) {
        guard let index = index else { return }
        gender = getGenderOptions()[index]
    }
    
    func getGender() -> (gender: String, isValid: Bool) {
        return (gender: gender, isValid: true)
    }
    
    func setAgeGroup(index: Int?) {
        guard let index = index else { return }
        ageGroup = getAgeGroups()[index]
    }
    
    func getAgeGroup() -> (ageGroup: String, isValid: Bool) {
        return (ageGroup: ageGroup, isValid: true)
    }
    
    func setMedicalCondition(index: Int?) {
        guard let index = index else { return }
        medicalCondition = getMedicalConditions()[index]
    }
    
    func getMedicalCondition() -> (medicalCondition: String, isValid: Bool) {
        return (medicalCondition: medicalCondition, isValid: true)
    }
    
    func saveData() {
        DataManager.setUserData(user: UserInfo(name: name, gender: gender, ageGroup: ageGroup, medicalCondition: medicalCondition, calibrationData: nil))
    }
    
}

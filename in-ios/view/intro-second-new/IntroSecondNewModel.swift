//
//  IntroSecondNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class IntroSeconNewModel: BaseModel {
    
    private var name: String = ""
    private var gender: String = Constant.DefaultValues.GEDNER_OPTIONS[0]
    private var ageGroup: String = Constant.DefaultValues.AGE_GROUPS[0]
    private var medicalCondition: String = Constant.DefaultValues.MEDICAL_CONDITIONS[0]
    
    func getGenderOptions() -> Array<String> {
        return Constant.DefaultValues.GEDNER_OPTIONS
    }
    
    func getAgeGroups() -> Array<String> {
        return Constant.DefaultValues.AGE_GROUPS
    }
    
    func getMedicalConditions() -> Array<String> {
        return Constant.DefaultValues.MEDICAL_CONDITIONS
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return name
    }
    
    func setGender(gender: String) {
        self.gender = gender
    }
    
    func getGender() -> String {
        return gender
    }
    
    func setAgeGroup(ageGroup: String) {
        self.ageGroup = ageGroup
    }
    
    func getAgeGroup() -> String {
        return ageGroup
    }
    
    func setMedicalCondition(medicalCondition: String) {
        self.medicalCondition = medicalCondition
    }
    
    func getMedicalCondition() -> String {
        return medicalCondition
    }
    
}

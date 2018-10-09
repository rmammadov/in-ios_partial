//
//  IntroSeconNewViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroSecondNewViewModel: BaseViewModel {

    let model: IntroSecondNewModel = IntroSecondNewModel()
    
    func getGenderOptions() -> Array<String> {
        return model.getGenderOptions()
    }
    
    func getAgeGroups() -> Array<String> {
        return model.getAgeGroups()
    }
    
    func getMedicalConditions() -> Array<String> {
        return model.getMedicalConditions()
    }
    
    func setName(name: String?) {
        model.setName(name: name)
    }
    
    func getName() -> (name: String, isValid: Bool) {
        return model.getName()
    }
    
    func setGender(index: Int?) {
        model.setGender(index: index)
    }
    
    func getGender() -> (gender: String, isValid: Bool) {
        return model.getGender()
    }
    
    func setAgeGroup(index: Int?) {
        model.setAgeGroup(index: index)
    }
    
    func getAgeGroup() -> (ageGroup: String, isValid: Bool)  {
        return model.getAgeGroup()
    }
    
    func setMedicalCondition(index: Int?) {
        model.setMedicalCondition(index: index)
    }
    
    func getMedicalCondition() -> (medicalCondition: String, isValid: Bool) {
        return model.getMedicalCondition()
    }
    
    func saveData() {
        model.saveData()
    }
}

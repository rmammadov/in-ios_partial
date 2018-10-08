//
//  IntroSeconNewViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroSeconNewViewModel: BaseViewModel {

    let model: IntroSeconNewModel = IntroSeconNewModel()
    
    func getGenderOptions() -> Array<String> {
        return model.getGenderOptions()
    }
    
    func getAgeGroups() -> Array<String> {
        return model.getAgeGroups()
    }
    
    func getMedicalConditions() -> Array<String> {
        return model.getMedicalConditions()
    }
    
    func setName(name: String) {
        model.setName(name: name)
    }
    
    func getName() -> String {
        return model.getName()
    }
    
    func setGender(gender: String) {
        model.setGender(gender: gender)
    }
    
    func getGender() -> String {
        return model.getGender()
    }
    
    func setAgeGroup(ageGroup: String) {
        model.setAgeGroup(ageGroup: ageGroup)
    }
    
    func getAgeGroup() -> String  {
        return model.getAgeGroup()
    }
    
    func setMedicalCondition(medicalConditon: String) {
        model.setMedicalCondition(medicalCondition: medicalConditon)
    }
    
    func getMedicalCondition() -> String {
        return model.getMedicalCondition()
    }
    
    func saveData() {
        model.saveData()
    }
}

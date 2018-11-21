//
//  SettingsAccountViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SettingsAccountViewModel: BaseViewModel {
    
    private var model = SettingsAccountModel()
    private var isValid: Variable<Bool> = Variable(true)
    
    let ages = Constant.DefaultValues.AGE_GROUPS
    let genders = Constant.DefaultValues.GEDNER_OPTIONS
    let medicalConditions = Constant.DefaultValues.MEDICAL_CONDITIONS
    
    var name: String = ""
    var gender: String = ""
    var age: String = ""
    var medicalCondition: String = ""
    
    func loadData() -> UserInfo? {
        name = model.userInfo?.name ?? ""
        gender = model.userInfo?.gender ?? ""
        age = model.userInfo?.ageGroup ?? ""
        medicalCondition = model.userInfo?.medicalCondition ?? ""
        return model.userInfo
    }
    
    func validateForm() {
        guard !name.isEmpty, !gender.isEmpty, !age.isEmpty, !medicalCondition.isEmpty else {
            isValid.value = false
            return
        }
        isValid.value = true
    }
    
    func getValidationObserver() -> Observable<Bool> {
        return isValid.asObservable()
    }
    
    func saveData() {
        model.save(name: name, gender: gender, age: age, medicalCondition: medicalCondition)
    }
    
    
}

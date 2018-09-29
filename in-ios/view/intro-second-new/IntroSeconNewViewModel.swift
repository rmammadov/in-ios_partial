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
    
}

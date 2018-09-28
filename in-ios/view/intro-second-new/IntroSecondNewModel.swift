//
//  IntroSecondNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class IntroSeconNewModel: BaseModel {
    
    private var arrayAgeGroups: Array<String> = ["5 - 10 years old", "11 - 20 years old", "31 - 30 years old", "31 - 40 years old"]
    private var arrayMedicalConditions: Array<String> = ["None", "Stroke", "Amytrophic Lateral", "Sclerosis"]
    
    func getAgeGroups() -> Array<String> {
        return arrayAgeGroups
    }
    
    func getMedicalConditions() -> Array<String> {
        return arrayMedicalConditions
    }
    
}

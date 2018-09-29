//
//  IntroSecondNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class IntroSeconNewModel: BaseModel {
    
    private var arrayGenderOptions: Array<String> = ["Male", "Female"]
    private var arrayAgeGroups: Array<String> = ["0 - 11 years old", "12 - 17 years old", "18 - 23 years old", "24 - 29 years old", "30 - 49 years old", "50 - 64 years old", "65 - 80 years old", "80 - 95 years old", "96+ years old"]
    private var arrayMedicalConditions: Array<String> = ["None", "Stroke", "Amyotrophic Lateral Sclerosis", "Spinal Muscular Atrophy", "Multiple Sclerosis", "Guillain-Barre Syndrome", "Alzheimer’s Disease", "Alzheimer’s Disease"]
    
    func getGenderOptions() -> Array<String> {
        return arrayGenderOptions
    }
    
    func getAgeGroups() -> Array<String> {
        return arrayAgeGroups
    }
    
    func getMedicalConditions() -> Array<String> {
        return arrayMedicalConditions
    }
    
}

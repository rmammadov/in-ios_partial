//
//  IntroFifthModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation


class IntroFifthModel: BaseModel {

    private var arrayMedicalConditions: Array<String> = ["None", "Stroke", "Amytrophic Lateral", "Sclerosis"]
    
    func getMedicalConditions() -> Array<String> {
        return arrayMedicalConditions
    }
}

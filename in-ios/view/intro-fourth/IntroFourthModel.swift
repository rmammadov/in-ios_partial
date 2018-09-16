//
//  IntroFourthModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation


class IntroFourthModel: BaseModel {
    
    private var arrayAgeGroups: Array<String> = ["5 - 10 years old", "11 - 20 years old", "31 - 30 years old", "31 - 40 years old"]
    
    func getAgeGroups() -> Array<String> {
        return arrayAgeGroups
    }
}

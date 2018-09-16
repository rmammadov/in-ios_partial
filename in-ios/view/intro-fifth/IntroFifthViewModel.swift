//
//  IntroFifthViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroFifthViewModel: BaseViewModel {

    let model: IntroFifthModel = IntroFifthModel()
    
    func getMedicalConditions() -> Array<String> {
        return model.getMedicalConditions()
    }
    
}

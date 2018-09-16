//
//  IntroFourthViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroFourthViewModel: BaseViewModel {
    
    let model: IntroFourthModel = IntroFourthModel()
    
    func getAgeGroups() -> Array<String> {
        return model.getAgeGroups()
    }

}

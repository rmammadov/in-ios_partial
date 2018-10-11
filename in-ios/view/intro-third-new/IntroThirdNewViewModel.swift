//
//  IntroThirdNewViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroThirdNewViewModel: BaseViewModel {
    
    private let model: IntroThirdNewModel = IntroThirdNewModel()
    
    func getTag() -> Int {
        return model.getTag()
    }
    
    func uploadScreenShot(image: UIImage) {
        model.uploadScreenShot(image: image)
    }
    
    func postProfileData() {
        model.postProfileData()
    }
}


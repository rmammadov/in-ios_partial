//
//  IntroThirdNewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import UIKit

class IntroThirdNewModel: BaseModel {
    
    private var index = 0
    private var tags: Array = Constant.CalibrationConfig.CALIBRATION_TAGS
    
    func getTag() -> Int {
        var tag: Int?
        if index < tags.count {
            tag = tags[index]
            index = index + 1
        } else {
            tag = 0
            index = 0
        }
        return tag!
    }
    
    func uploadScreenShot(image: UIImage, predictionDetail: PredictionDetail) {
        DataManager.uploadImage(image: image, predictionDetail: predictionDetail)
    }
    
    func postProfileData() {
        DataManager.postProfileData()
    }
}

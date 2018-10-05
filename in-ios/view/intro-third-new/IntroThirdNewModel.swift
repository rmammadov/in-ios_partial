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
    
    private var tagCalibrationBtn: Int = 110
    private var btnCalibrationPrevious: UIButton?
    private var index = 0
    private var tags: Array = [110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122]
    
    func setTag(tag: Int) {
        tagCalibrationBtn = tag
    }
    
    func getTag() -> Int {
        var tag: Int?
        if index < tags.count - 1 {
            tag = tags[index]
            index += 1
        } else {
            tag = 0
            index = 0
        }
        return tag!
    }
    
    func setPreviousBtn(btn: UIButton) {
        btnCalibrationPrevious = btn
    }
    
    func getPreviousBtn() -> UIButton? {
        return btnCalibrationPrevious
    }
    
}

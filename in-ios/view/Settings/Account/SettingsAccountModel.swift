//
//  SettingsAccountModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class SettingsAccountModel: BaseModel {

    let userInfo: UserInfo?
    
    override init() {
        userInfo = DataManager.getUserData()
    }
    
    func save(name: String, gender: String, age: String, medicalCondition: String) {
        let userInfo = UserInfo(name: name,
                                gender: gender,
                                ageGroup: age,
                                medicalCondition: medicalCondition,
                                calibrationData: self.userInfo?.calibrationData)
        DataManager.setUserData(user: userInfo)
    }
    
}

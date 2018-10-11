//
//  ProfileData.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/11/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct ProfileData: Codable {
    
    let id: Int64?
    let data: Array<UserInfo>?
    let files: Array<File>?
}

struct File: Codable {
    
    let size: Int
    let url: String
}

struct UserInfo: Codable {
    
    let name: String
    let gender: String
    let ageGroup: String
    let medicalCondition: String
}

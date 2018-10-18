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
    let version: Int?
    let device_id: String?
    let data: Array<UserInfo>
}

struct UserInfo: Codable {
    
    let name: String
    let gender: String
    let ageGroup: String
    let medicalCondition: String
    var calibrationData: Array<CalibrationData>?
}

struct File: Codable {
    
    let size: Int
    let url: String
}

struct CalibrationData: Codable {
    
    let target_x: Double
    let target_y: Double
    let prediction_x: Double
    let prediction_y: Double
    let calibrationFeatures: Array<String>
    let facialFeatures: Array<Double>
    let eyeCenters: Array<Array<Double>>
    var file: File?
}

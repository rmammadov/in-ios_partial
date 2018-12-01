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
    var appSettings: AppSettins?
    var deviceDetails: DeviceDetails?
}

struct CalibrationData: Codable {
    
    var cross_x: Float?
    var cross_y: Float?
    let pointer_x: Double
    let pointer_y: Double
    let prediction_x: Double
    let prediction_y: Double
    let calibrationFeatures: Array<String>
    let facialDetails: Array<Double>
    let eyeCenters: Array<Array<Double>>
    var file: File?
    var deviceOrientation: String
}

struct AppSettins: Codable {
    
    var language: String?
    var autoSelectDelay: String?
    var tileSize: Int?
    var isSoundEnabled: Bool?
}

struct DeviceDetails: Codable {
    
    var model: String?
    var type: String?
    var osVersion: String?
    var screenResolution: String?
}

struct File: Codable {
    
    let size: Int
    let url: String
}

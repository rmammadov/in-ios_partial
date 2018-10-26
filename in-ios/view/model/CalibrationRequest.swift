//
//  CalibrationRequest.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/25/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct CalibrationRequest: Codable {
    
    let profile_data: ProfileDataId
}

struct ProfileDataId: Codable {
    
    let id: Int64
}

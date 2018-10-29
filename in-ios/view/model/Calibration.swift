//
//  Calibration.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/25/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct Calibration: Decodable {
    
    let id: Int
    let x_model_url: String
    let y_model_url: String
    let created_at: String
    let updated_at: String
}

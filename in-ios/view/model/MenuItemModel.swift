//
//  MenuItem.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct MenuItem: Decodable {
    
    let subMenuItemIds: Array<Int>
    let translatoions: [String: [String: String]]
    let id: Int
    let name: String
    let icon: [String: String]
    let roles: Array<String>
}

//
//  String.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/8/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}

//
//  WebViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class WebviewModel: BaseModel {
    
    private var htmlString: String?
    
    func setHtml(string: String) {
        htmlString = string
    }
    
    func getHtml() -> String? {
        return htmlString
    }
}

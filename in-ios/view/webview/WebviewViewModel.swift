//
//  WebViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class WebviewViewModel: BaseViewModel {

    private let model = WebviewModel()
    
    func setHtml(string: String) {
        model.setHtml(string: string)
    }
    
    func getHtml() -> String? {
        return model.getHtml()
    }
}

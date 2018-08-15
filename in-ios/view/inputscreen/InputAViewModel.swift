//
//  InputViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class InputAViewModel: BaseViewModel {

    var status = Variable<Int>(0)
    
    fileprivate var screen: InputScreen?
    fileprivate var parentMenuItem: MenuItem?
    
    func setParentMenuItem(item: MenuItem) {
        self.parentMenuItem = item
    }
    
    func loadScreen() {
        self.screen = DataManager.getInputScreens().screens[0]
    }
    
    func getTitle() -> String? {
        return self.screen?.translations[0].title
    }
    
    func getSpeakButtonStatus() -> Bool? {
        return screen?.disable_text_to_speech
    }
}

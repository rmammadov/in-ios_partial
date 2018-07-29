//
//  HomeViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class HomeViewModel: NSObject {
    
    let requestHandler = ApiRequestHandler()
    
    func getMenuItems() {
        self.requestHandler.getMenuItems()
    }
    
    func textToSpech() {
         SpeechHelper.play(text: "You can omit the rate property entirely to have a natural-speed voice, or change the language to (English, American accent)(English, Australian accent) or whichever other accents Apple chooses to add in the future.", language: "en-US")
    }
}

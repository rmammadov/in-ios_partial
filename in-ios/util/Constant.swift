//
//  Constant.swift
//  in-ios
//
//  Created by Rahman Mammadov on 6/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import AVKit

struct Constant {
    
    struct DefaultConfig {
        static let TIMEOUT_FOR_REQUEST: Double = 15.0
        static let TIMEOUT_FOR_RESOURCE: Double = 30.0
        static let COUNT_ROW_ITEMS: Int = 4
        static let COUNT_COLUMN_ITEMS: Int = 5
        static let RESOLUTION_VIDEO_INPUT: AVCaptureSession.Preset = .cif352x288
    }
    
    struct Url {
        static let HOST_API_BETA: String = "http://api-beta1.innodem-neurosciences.com/"
        static let URL_EXTENSION_API: String = "api/"
        static let URL_EXTENSION_MENU_ITEMS: String = "menu-items"
        static let URL_EXTENSION_INPUT_SCREENS: String = "input-screens"
    }
    
    struct MenuConfig {
        static let NAME_TOP_MENU_ITEM: String = "root"
        static let NAME_IAM_MENU_ITEM: String = "I am"
        static let IAM_NOT_FOUND_INDEX: Int = 999
        static let PREVIOUS_ITEM_NAME = "Previous"
        static let NEXT_ITEM_NAME = "Next"
    }
    
    struct InputScreen {
        static let TYPE_A: String = "InputScreenA"
    }
    
    struct AnimationConfig {
        static let MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION: Double = 0.5
        static let MENU_ITEM_ANIMATION_DURATION: Double = 4.0
        static let MENU_ITEM_ANIMATION_COUNT: Float = 1.0
    }
}

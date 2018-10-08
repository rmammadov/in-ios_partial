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
        static let GAZE_PREDICTION_AVERAGING_COUNT: Int = 3
    }
    
    struct Url {
        static let HOST_API_BETA: String = "http://api-beta1.innodem-neurosciences.com/"
        static let URL_EXTENSION_API: String = "api/"
        static let URL_EXTENSION_MENU_ITEMS: String = "menu-items"
        static let URL_EXTENSION_INPUT_SCREENS: String = "input-screens"
        static let URL_EXTENSION_LEGAL_DOCUMENTS: String = "legal-documents"
    }
    
    struct DefaultValues {
        static let GEDNER_OPTIONS: Array<String> = ["Male", "Female"]
        static let AGE_GROUPS: Array<String> = ["0 - 11 years old", "12 - 17 years old", "18 - 23 years old", "24 - 29 years old", "30 - 49 years old", "50 - 64 years old", "65 - 80 years old", "80 - 95 years old", "96+ years old"]
        static let MEDICAL_CONDITIONS: Array<String> = ["None", "Stroke", "Amyotrophic Lateral Sclerosis", "Spinal Muscular Atrophy", "Multiple Sclerosis", "Guillain-Barre Syndrome", "Alzheimer’s Disease", "Alzheimer’s Disease"]
    }
    
    struct MenuConfig {
        static let NAME_TOP_MENU_ITEM: String = "root"
        static let NAME_IAM_MENU_ITEM: String = "I am <first name>"
        static let IAM_NOT_FOUND_INDEX: Int = 999
        static let PREVIOUS_ITEM_NAME = "Previous"
        static let NEXT_ITEM_NAME = "Next"
        static let VOLUME_UP = "Volume up"
        static let VOLUME_DOWN = "Volume down"
    }
    
    struct AnimationConfig {
        static let MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION: Double = 0.5
        static let MENU_ITEM_ANIMATION_DURATION: Double = 4.0
        static let MENU_ITEM_ANIMATION_COUNT: Float = 1.0
    }
    
    struct CalibrationConfig {
        static let CALIBRATION_STEP_DURATION: Double = 4.0
        static let CALIBRATION_TAGS: Array = [114, 120, 117, 112, 118, 110, 121, 113, 122, 115, 111, 119, 116]
    }
}

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
        static let TIMEOUT_FOR_REQUEST: Double = 30.0
        static let TIMEOUT_FOR_RESOURCE: Double = 60.0
        static let COUNT_ROW_ITEMS: Int = 4
        static let COUNT_COLUMN_ITEMS: Int = 5
        static let RESOLUTION_VIDEO_INPUT: AVCaptureSession.Preset = .high
        static let GAZE_PREDICTION_AVERAGING_COUNT: Int = 10
    }
    
    struct Url {
        static let HOST_API_BETA: String = "https://api-beta1.innodem-neurosciences.com/"
        static let URL_EXTENSION_API: String = "api/"
        static let URL_EXTENSION_MENU_ITEMS: String = "menu-items"
        static let URL_EXTENSION_INPUT_SCREENS: String = "input-screens"
        static let URL_EXTENSION_LEGAL_DOCUMENTS: String = "legal-documents"
        static let URL_EXTENSION_LEGAL_ACCEPTATIONS: String = "acceptations"
        static let URL_EXTENSION_FILES: String = "files"
        static let URL_EXTENSION_PROFILE_DATAS: String = "profile-datas"
        static let URL_EXTENSION_CALIBRATIONS: String = "calibrations"
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
        static let ALL_CLEAR = "AC"
        static let EQUAL_SIGN = "="
    }
    
    struct AnimationConfig {
        static let MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION: Double = 0.001
        static let MENU_ITEM_ANIMATION_DURATION: Double = 4.0
        static let MENU_ITEM_ANIMATION_COUNT: Float = 1.0
    }
    
    struct CalibrationConfig {
        static let STANDART_CALIBRATION_STEP_DURATION: Double = 3.0
        static let STANDART_CALIBRATION_STEP_DATA_COLLECTION_DURATION: Double = STANDART_CALIBRATION_STEP_DURATION / 2
        static let MOVING_CALIBRATION_STEP_DURATION: Double = 4.0
        static let MOVING_CALIBRATION_STEP_DATA_COLLECTION_DURATION: Double = 0.25
        static let CALIBRATION_TAGS_STEPS: [Int] = [1,10,5,4,9,2,8,7,11,6,12,13,3]
    }
    
    struct InputValidationConfig {
        static let REGEX_NAME = "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"
        static let REGEX_GENDER = "^male$|^female$"
    }
}

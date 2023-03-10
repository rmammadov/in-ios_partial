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
        static let GAZE_PREDICTION_AVERAGING_COUNT: Int = 3
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
        static let URL_EXTENSION_USAGE = "usages"
    }
    
    struct DefaultValues {
        static let GEDNER_OPTIONS: Array<String> = [
            "male".localized, "female".localized
        ]
        static let AGE_GROUPS: Array<String> = [
            "0-11years".localized, "12-17years".localized, "18-23years".localized, "24-29years".localized, "30-49years".localized,
            "50-64years".localized, "65-80years".localized, "80-95years".localized, "96years".localized
        ]
        static let MEDICAL_CONDITIONS: Array<String> = [
            "none".localized,
            "stroke".localized,
            "amyotrophic_lateral_sclerosis".localized,
            "spinal_muscular_atrophy".localized,
            "multiple_sclerosis".localized,
            "guillain_barre_syndrome".localized,
            "alzheimer_disease".localized,
            "parkinson_disease".localized,
            "progressive_supranuclear".localized,
            "cerebral_palsy".localized,
            "muscular_dystrophy".localized,
            "corticobasal_degeneration".localized,
            "progressive_ataxia".localized
        ]
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
        static let MENU_ITEM_ANIMATION_DURATION: Double = 1.5
        static let MENU_ITEM_ANIMATION_COUNT: Float = 1.0
    }
    
    struct CalibrationConfig {
        static let STANDART_CALIBRATION_STEP_DURATION: Double = 3.0
        static let STANDART_CALIBRATION_STEP_DATA_COLLECTION_DURATION: Double = STANDART_CALIBRATION_STEP_DURATION / 2
        static let MOVING_CALIBRATION_STEP_DURATION: Double = 4.0
        static let MOVING_CALIBRATION_STEP_DATA_COLLECTION_DURATION: Double = 0.25
        static let CALIBRATION_TAGS_STEPS: [Int] = [1,10,5,4,9,2,8,7,11,6,12,13,3]
    }
    
    struct ItemSize {
        static let POINTER_HEIGHT: CGFloat = 55.0
        static let POINTER_WIDTH: CGFloat = 50.0
    }
    
    struct InputValidationConfig {
        static let REGEX_NAME = "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"
        static let REGEX_GENDER = "^male$|^female$"
    }
}

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
        static let NAME_IAM_MENU_ITEM: String = "I am"
        static let IAM_NOT_FOUND_INDEX: Int = 999
        static let PREVIOUS_ITEM_NAME = "Previous"
        static let NEXT_ITEM_NAME = "Next"
    }
    
    struct ButtonType {
        static let INPUT_SCREEN_OPEN: String = "ButtonInputScreenOpen"
        static let BUTTONS_SIMPLE: String = "ButtonSimple"
    }
    
    enum InputScreenId: Int {
        case more = 2
        case questionsK = 4
        case day = 5
        case month = 6
        case dateAndNumbers = 8
        case greetings = 9
        case responses = 11
        case actions = 12
        case questionsC = 13
        case goodbyes = 14
        case to = 15
        case cares = 17
        case items = 18
        case comfort = 19
        case reposition = 20
        case food = 21
        case medicine = 22
        case lights = 23
        case toSee = 24
        case toClean = 25
        case miscellaneous = 26
        case positiveMind = 27
        case negativeMind = 29
        case physicalSymptoms = 30
        case breathingGiSymptoms = 31
        
        var buttonsTitle: String? {
            switch self {
            case .more: return "Keywords - More"
            case .day: return "Day"
            case .month: return "Month"
            case .questionsK: return "Keywords - Questions"
            case .questionsC: return "Conversations - Questions"
            case .dateAndNumbers: return "Keywords - Date & Numbers"
            case .greetings: return "Conversations - Greetings"
            case .responses: return "Conversations - Responses"
            case .actions: return "Conversations - Actions"
            case .goodbyes: return "Conversations - Goodbyes"
            case .to: return "I want - To"
            case .cares: return "I want - Cares"
            case .items: return "I want - Items"
            case .comfort: return "I want - Comfort"
            case .reposition: return "I want - Reposition"
            case .food: return "I want - Food"
            case .medicine: return "I want - Medicine"
            case .lights: return "I want - Lights"
            case .toSee: return "I want - To see"
            case .toClean: return "I want - To clean"
            case .miscellaneous: return "I want - Miscellaneous"
            case .positiveMind: return "I am - Positive Mind"
            case .negativeMind: return "I am - Negative mind"
            case .physicalSymptoms: return "I am - Physical symptoms"
            case .breathingGiSymptoms: return "I am - Breathing/GI symptoms"
            }
        }
        var type: String {
            switch self {
            case .dateAndNumbers:
                return InputScreen.TYPE_C
            default:
                return InputScreen.TYPE_B
            }
        }
    }
    
    struct InputScreen {
        static let TYPE_A: String = "InputScreenA"
        static let TYPE_B: String = "InputScreenB"
        static let TYPE_C: String = "InputScreenC"
        static let TYPE_D: String = "InputScreenD"
        static let TYPE_E: String = "InputScreenE"
        static let TYPE_F: String = "InputScreenF"
    }
    
    struct AnimationConfig {
        static let MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION: Double = 0.5
        static let MENU_ITEM_ANIMATION_DURATION: Double = 4.0
        static let MENU_ITEM_ANIMATION_COUNT: Float = 1.0
    }
}

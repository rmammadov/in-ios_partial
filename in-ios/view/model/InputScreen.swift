//
//  InputScreen.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

struct InputScreen: Decodable {
    
    let id: Int
    let disableTextToSpeech: Bool
    let translations: [Translation]
    let buttons: [ButtonInputScreen]?
    let background: Background?
    let backgroundTransparency: Double?
    let previousButton: ButtonInputScreen?
    let nextButton: ButtonInputScreen?
    let type: InputScreenType
    let backButton: ButtonInputScreen?
    let clearButton: ButtonInputScreen?
    let tabs: [Tab]?
    
    enum InputScreenType: String, Decodable {
        case inputScreenA = "InputScreenA"
        case inputScreenB = "InputScreenB"
        case inputScreenC = "InputScreenC"
        case inputScreenD = "InputScreenD"
        case inputScreenE = "InputScreenE"
        case inputScreenF = "InputScreenF"
        case inputScreenG = "InputScreenG"
        case inputScreenH = "InputScreenH"
    }
}

extension InputScreen {
    
    enum InputScreenKeys: String, CodingKey {
        case id
        case disableTextToSpeech = "disable_text_to_speech"
        case translations = "translations"
        case buttons = "buttons"
        case background = "background"
        case backgroundTransparency = "background_transparency"
        case previousButton = "previous_button"
        case nextButton = "next_button"
        case backButton = "back_button"
        case clearButton = "clear_button"
        case tabs = "tabs"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InputScreenKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let disableTextToSpeech: Bool = try container.decode(Bool.self, forKey: .disableTextToSpeech)
        let translations: [Translation] = try container.decode([Translation].self, forKey: .translations)
        let type: InputScreenType = try container.decode(InputScreenType.self, forKey: .type)
        
        let buttons: [ButtonInputScreen]? = try container.decodeIfPresent([ButtonInputScreen].self, forKey: .buttons)
        let background: Background? = try container.decodeIfPresent(Background.self, forKey: .background)
        let backgroundTransparency: Double? = try container.decodeIfPresent(Double.self, forKey: .backgroundTransparency)
        let previousButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .previousButton)
        let nextButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .nextButton)
        let backButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .backButton)
        let clearButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .clearButton)
        let tabs: [Tab]? = try container.decodeIfPresent([Tab].self, forKey: .tabs)
        
        self.init(id: id, disableTextToSpeech: disableTextToSpeech, translations: translations, buttons: buttons,
                  background: background, backgroundTransparency: backgroundTransparency,
                  previousButton: previousButton, nextButton: nextButton, type: type, backButton: backButton,
                  clearButton: clearButton, tabs: tabs)
    }
}

struct ButtonInputScreen: Decodable {
    
    var disableTextToSpeech: Bool?
    var icon: IconMenuItem? = nil
    var translations: [Translation]?
    var type: ButtonType
    
    /// ButtonInputScreenOpen properties:
    var inputScreenId: Int? = nil
    
    /// ButtonColored properties:
    var mainColor: UIColor?
    var gradientColor: UIColor?
    
    /// ButtonImageMap properties:
    var picture: Icon?
    var bubbles: [Bubble]?
    
    enum CodingKeys: String, CodingKey {
        case disableTextToSpeech = "disable_text_to_speech"
        case inputScreenId = "input_screen_id"
        case mainColor = "main_color"
        case gradientColor = "gradient_color"
        case icon, translations, type, picture, bubbles
    }
    
    enum ButtonType: String, Decodable {
        case colored = "ButtonColored"
        case simple = "ButtonSimple"
        case inputScreenOpen = "ButtonInputScreenOpen"
        case imageMap = "ButtonImageMap"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ButtonInputScreen.CodingKeys.self)
        self.type = try container.decode(ButtonType.self, forKey: .type)
        self.disableTextToSpeech = try container.decodeIfPresent(Bool.self, forKey: .disableTextToSpeech)
        self.icon = try container.decodeIfPresent(IconMenuItem.self, forKey: .icon)
        self.translations = try container.decodeIfPresent([Translation].self, forKey: .translations)
        self.inputScreenId = try container.decodeIfPresent(Int.self, forKey: .inputScreenId)
        if let mainColorHex = try container.decodeIfPresent(String.self, forKey: .mainColor) {
            self.mainColor = UIColor(hex: mainColorHex)
        }
        if let gradientColorHex = try container.decodeIfPresent(String.self, forKey: .gradientColor) {
            self.gradientColor = UIColor(hex: gradientColorHex)
        }
        self.picture = try container.decodeIfPresent(Icon.self, forKey: .picture)
        self.bubbles = try container.decodeIfPresent([Bubble].self, forKey: .bubbles)
    }
}

struct Background: Decodable {
    
    var id: Int?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url
    }
}

struct Tab: Decodable {
    let panelScreenId: Int
    
    enum CodingKeys: String, CodingKey {
        case panelScreenId = "panel_screen_id"
    }
}

struct Icon: Decodable {
    let id: Int
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url), let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = nil
        }
    }
}

struct Bubble: Decodable {
    let isDisableTextToSpeech: Bool
    let coords: String
    let anchorCords: CGPoint?
    let position: Int
    let translations: [Translation]
    
    enum CodingKeys: String, CodingKey {
        case isDisableTextToSpeech = "disable_text_to_speech"
        case coords, position, translations
        case anchorCords = "anchor_coords"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isDisableTextToSpeech = try container.decode(Bool.self, forKey: .isDisableTextToSpeech)
        self.coords = try container.decode(String.self, forKey: .coords)
        let aCoordsComp = try container.decode(String.self, forKey: .anchorCords).components(separatedBy: ",")
        if aCoordsComp.count == 2, let x = Int(aCoordsComp[0]), let y = Int(aCoordsComp[1]) {
            self.anchorCords = CGPoint(x: x, y: y)
        } else {
            self.anchorCords = nil
        }
        self.position = try container.decode(Int.self, forKey: .position)
        self.translations = try container.decode([Translation].self, forKey: .translations)
    }
}

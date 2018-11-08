//
//  Translation.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct Translation: Decodable {
    var locale: String
    var label: String
    var labelTextToSpeech: String
    
    enum CodingKeys: String, CodingKey {
        case labelTextToSpeech = "label_text_to_speech"
        case titleTextToSpeech = "title_text_to_speech"
        case locale, label, title
    }
    
    init(locale: String, label: String, textToSpeech: String) {
        self.locale = locale
        self.label = label
        self.labelTextToSpeech = textToSpeech
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let locale = try container.decode(String.self, forKey: .locale)
        self.locale = locale
        if let label = try container.decodeIfPresent(String.self, forKey: .label) {
            self.label = label
        } else if let label = try container.decodeIfPresent(String.self, forKey: .title) {
            self.label = label
        } else {
            self.label = ""
        }
        if let labelTextToSpeech = try container.decodeIfPresent(String.self, forKey: .labelTextToSpeech) {
            self.labelTextToSpeech = labelTextToSpeech
        } else if let labelTextToSpeech = try container.decodeIfPresent(String.self, forKey: .titleTextToSpeech) {
            self.labelTextToSpeech = labelTextToSpeech
        } else {
            self.labelTextToSpeech = label
        }
    }
}

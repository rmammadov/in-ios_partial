//
//  LegalDocument.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct LegalDocument: Decodable {
    
    let name: String
    let translations: [TranslationLegalDocument]
}

struct TranslationLegalDocument: Decodable {
    
    var locale: String?
    var title: String?
    var text: String?
}

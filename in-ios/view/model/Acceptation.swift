//
//  Acceptation.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct Acceptation: Codable {
    
    let locale: String
    let acceptedText: String
    let acceptedLegalDocuments: Array<Document>
    
    enum CodingKeys: String, CodingKey {
        case acceptedText = "accepted_text"
        case acceptedLegalDocuments = "accepted_legal_documents"
        case locale
    }
    
}

struct Document: Codable {
    
    let name: String?
    let revision: Int?
    
}

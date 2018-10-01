//
//  LegalDocuments.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct LegalDocuments {
    
    let legalDocuments: [LegalDocument]
}

extension LegalDocuments {
    
    func getLegalDocument(title: String) -> LegalDocument {
        return legalDocuments.filter{ ($0.translations.first?.title)! == title}.first!
    }
}

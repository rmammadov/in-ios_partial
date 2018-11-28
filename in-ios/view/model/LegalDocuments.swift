//
//  LegalDocuments.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct LegalDocuments {
    
    var legalDocuments: Array<LegalDocument>?
}

extension LegalDocuments {
    
    func getLegalDocument(name: String) -> LegalDocument? {
        return legalDocuments?.filter{ ($0.name) == name}.first
    }
}

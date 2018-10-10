//
//  IntroFirstModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class IntroFirstModel: BaseModel {
    
    func getLegalDocuments() -> LegalDocuments {
        return DataManager.getLegalDocuments()
    }
    
    func getLegalDocument(name: String) -> LegalDocument {
        return DataManager.getLegalDocuments().getLegalDocument(name: name)
    }
    
    func getAcceptationStatus() {
        let acceptation: Acceptation = Acceptation(locale: "en", acceptedText: "test", acceptedLegalDocuments: [Document(name: "terms_of_sales")])
        DataManager.getAcceptationStatus(acceptation: acceptation)
    }
}

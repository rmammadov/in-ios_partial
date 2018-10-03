//
//  IntroFirstViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroFirstViewModel: BaseViewModel {

    private let model: IntroFirstModel = IntroFirstModel()
    
    private var selectedName: String = " "
    
    func getLegalDocuments() -> LegalDocuments {
        return model.getLegalDocuments()
    }
    
    func getLegalDocument(name: String) -> LegalDocument {
        return model.getLegalDocument(name: name)
    }
    
    func setSelectedLegal(name: String) {
        selectedName = name
    }
    
    func getSelectedLegalName() -> String {
        return selectedName
    }
}

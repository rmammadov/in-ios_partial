//
//  PersistanceDataHandler.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/23/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import CoreData

class PersistanceDataHandler {
    
    let fileNameHelper = FileNamingHelper()
    
    static func saveCoreDataChanges() {
        PersistanceService.shared.saveContext()
    }
    
    func saveLegalDocuments(documents: LegalDocuments) {
        guard let documents = documents.legalDocuments else { return }
        for document in documents {
            saveLegalDocument(document: document)
        }
    }
    
    func saveLegalDocument(document: LegalDocument) {
        let documentEntity = LegalDocumentsEntity(context: PersistanceService.shared.backgroundManagedObjectContext)
        documentEntity.id = fileNameHelper.getUnixTimestamp()
        documentEntity.name = document.name
        let legalDocumentTranslationEntity = TranslationsLegalDocumentEntity(context: PersistanceService.shared.context)
        for translation in document.translations {
            legalDocumentTranslationEntity.id = fileNameHelper.getUnixTimestamp()
            legalDocumentTranslationEntity.idDocument = documentEntity.id
            legalDocumentTranslationEntity.locale = translation.locale
            legalDocumentTranslationEntity.title = translation.title
            legalDocumentTranslationEntity.text = translation.text
        }
    }
    
    func saveProfileData(profileData: ProfileData) {
        let profileDataEntity = ProfileDataEntity(context: PersistanceService.shared.backgroundManagedObjectContext)
        profileDataEntity.id = profileData.id!
        profileDataEntity.version = Int16(profileData.version!)
        profileDataEntity.deviceId = profileData.device_id
        for userInfo in profileData.data {
            let userInfoEntity = UserInfoEntity(context: PersistanceService.shared.backgroundManagedObjectContext)
            userInfoEntity.id = Int64(fileNameHelper.getUnixTimestamp())
            userInfoEntity.profileDataId = profileData.id!
            userInfoEntity.name = userInfo.name
            userInfoEntity.gender = userInfo.gender
            userInfoEntity.ageGroup = userInfo.ageGroup
            userInfoEntity.medicalCondition = userInfo.medicalCondition
        }
    }
}

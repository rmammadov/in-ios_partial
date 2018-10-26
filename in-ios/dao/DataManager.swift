//
//  DataManager.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

enum DataStatus: Int {
    case notLoaded = 0
    case dataLoadingFailed = 1
    case menuItemsLoaded = 2
    case inputScreensLoaded = 3
    case legalDocumentsLoaded = 4
    case dataLoadingCompleted = 5
}

class DataManager {
    
    static var status = Variable<Int>(0)
    static let disposeBag = DisposeBag()
    
    static fileprivate var menuItems: MenuItems?
    static fileprivate var inputScreens: InputScreens?
    static fileprivate var legalDocuments: LegalDocuments?
    static fileprivate var calibrationData: Array<CalibrationData> = []
    static fileprivate var user: UserInfo?
    static fileprivate var profileData: ProfileData?
    static fileprivate var data: CalibrationData?
    static fileprivate var calibration: Calibration?
    
    static fileprivate let requestHandler = ApiRequestHandler()
    static fileprivate let fileNaming = FileNamingHelper()
    
    static func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.status.value != RequestStatus.failed.rawValue{
                if self.requestHandler.status.value == RequestStatus.completedMenuItems.rawValue {
                    self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
                    self.loadInputScreens()
                    self.status.value = DataStatus.menuItemsLoaded.rawValue
                } else if self.requestHandler.status.value == RequestStatus.completedInputScreens.rawValue {
                    self.inputScreens = InputScreens(screens: self.requestHandler.getInputScreens())
                    self.loadLegalDocuments()
                    self.status.value = DataStatus.inputScreensLoaded.rawValue
                } else if self.requestHandler.status.value == RequestStatus.completedLegalDocuments.rawValue {
                    self.legalDocuments = LegalDocuments(legalDocuments: self.requestHandler.getLegalDocuments())
                    self.status.value = DataStatus.dataLoadingCompleted.rawValue
                } else if self.requestHandler.status.value == RequestStatus.completedFile.rawValue {
                    guard let file = self.requestHandler.getFile() else { return }
                    guard var data = self.data else { return }
                    data.file = file
                    calibrationData.append(data)
                } else if self.requestHandler.status.value == RequestStatus.completedProfileData.rawValue {
                    guard let profileData = self.requestHandler.getProfileData() else { return }
                    self.profileData = profileData
                    self.requestHandler.getCalibrations(calibrationRequest: CalibrationRequest(profile_data: ProfileDataId(id: (self.profileData?.id)!)))
                } else if self.requestHandler.status.value == RequestStatus.completedCalibration.rawValue {
                    guard let calibration = self.requestHandler.getCalibration() else { return }
                    self.calibration = calibration
                }
            } else if self.requestHandler.status.value == RequestStatus.failed.rawValue {
                self.status.value = DataStatus.dataLoadingFailed.rawValue
            }
        }).disposed(by: disposeBag)
    }
    
    static func startLoadRequiredData() {
        self.loadMenuItems()
    }
    
    static func loadMenuItems() {
        self.requestHandler.requestMenuItems()
    }
    
    static func getMenuItems() -> MenuItems {
        return self.menuItems!
    }
    
    static func loadInputScreens() {
        self.requestHandler.requestInputScreens()
    }
    
    static func getAcceptationStatus(acceptation: Acceptation) {
        self.requestHandler.postAcceptation(acceptation: acceptation)
    }
    
    static func setCalibrationDataFor(image: UIImage, data: CalibrationData) {
        self.data = data
        guard let imageData: Data = image.jpegData(compressionQuality: 1.0) else { return }
        self.requestHandler.uploadFile(data: imageData)
    }
    
    static func postProfileData() {
        guard let profileData = getProfileData() else { return }
        self.requestHandler.postProfileData(profileData: profileData)
    }
    
    static func getProfileData() -> ProfileData? {
        guard var user = user else { return nil }
        user.calibrationData = calibrationData
        let deviceId = fileNaming.getDeviiceUUID()
        profileData = ProfileData(id: nil, version: 1, device_id: deviceId, data: [user])
        return profileData
    }
    
    static func getInputScreens() -> InputScreens {
        return self.inputScreens!
    }
    
    static func loadLegalDocuments() {
        self.requestHandler.requestLegalDocuments()
    }
    
    static func getLegalDocuments() -> LegalDocuments {
        return self.legalDocuments!
    }
    
    static func setUserData(user: UserInfo) {
        self.user = user
    }
    
    static func getUserData() -> UserInfo? {
        return user
    }

}

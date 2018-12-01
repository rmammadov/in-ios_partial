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
    case loadingCalibrationDataCompleted = 6
    case loadingModelCompleted = 7
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
    static fileprivate var xModelUrl: String?
    static fileprivate var yModelUrl: String?
    
    static fileprivate let requestHandler = ApiRequestHandler()
    static fileprivate let fileNaming = FileNamingHelper()
    static fileprivate let deviceDetailsHelper = DeviceDetailsHelper()
    
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
        
        self.user?.appSettings?.language = SettingsHelper.shared.language.rawValue
        self.user?.appSettings?.autoSelectDelay = SettingsHelper.shared.autoSelectDelay.rawValue
        self.user?.appSettings?.tileSize = SettingsHelper.shared.tileSize.rawValue
        self.user?.appSettings?.isSoundEnabled = SettingsHelper.shared.isSoundEnabled
        
        self.user?.deviceDetails?.type = deviceDetailsHelper.getDeviceType()
        self.user?.deviceDetails?.model = deviceDetailsHelper.getDeviceModel()
        self.user?.deviceDetails?.osVersion = deviceDetailsHelper.getScreenResolution()
        self.user?.deviceDetails?.osVersion = deviceDetailsHelper.getOsVersion()
    }
    
    static func getUserData() -> UserInfo? {
        return user
    }

    static func setXModelUrl(_ url: String) {
        self.xModelUrl = url
    }
    
    static func getXModelUrl() -> String? {
        return xModelUrl
    }
    
    static func setYModelUrl(_ url: String) {
        self.yModelUrl = url
    }
    
    static func getYModelUrl() -> String? {
        return yModelUrl
    }
    
    static func getOrientation() -> String? {
        return profileData?.data.first?.calibrationData?.first?.deviceOrientation
    }
}

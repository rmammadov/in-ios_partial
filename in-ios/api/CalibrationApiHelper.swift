//
//  CalibrationApiHelper.swift
//  in-ios
//
//  Created by Piotr Soboń on 07/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class CalibrationApiHelper: NSObject {
    
    private let uploadFileQueue = OperationQueue()
    private let operationQueue = OperationQueue()
    
    private var calibrationDataArray: [CalibrationData] = []
    private var profileData: ProfileData?
    private let session: URLSession
    
    override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        
        self.session = URLSession(configuration: config)
        
        super.init()
        
        self.uploadFileQueue.maxConcurrentOperationCount = 4
        
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func setCalibrationDataFor(image: UIImage, data: CalibrationData) {
        guard let imageData: Data = image.jpegData(compressionQuality: 1.0) else { return }
        uploadFile(imageData: imageData, calibrationData: data)
    }
    
    private func uploadFile(imageData: Data, calibrationData: CalibrationData) {
        var mutableCalibrationData = calibrationData
        let operation = UploadFileOperation(session: session, data: imageData, completionHandler: ({[weak self] (file) in
            print("UploadFileOperations count: \(self?.uploadFileQueue.operationCount ?? -1)")
            guard let `self` = self, let file = file else { return }
            mutableCalibrationData.file = file
            self.calibrationDataArray.append(mutableCalibrationData)
        }))
        uploadFileQueue.addOperation(operation)
    }
    
    func preparePostProfileOperation() {
        let operation = PostProfileOperation(session: session, apiHelper: self, completionHandler: { [weak self] profileData in
            guard let `self` = self else { return }
            self.profileData = profileData
            self.getCalibrations()
        })
        uploadFileQueue.operations.forEach{ operation.addDependency($0) }
        operationQueue.addOperation(operation)
    }
    
    func getCalibrationDataArray() -> [CalibrationData] {
        return self.calibrationDataArray
    }
    
    private func getCalibrations() {
        guard let profileDataId = self.profileData?.id else {
            print("Error getCalibrations: profileDataId is nil")
            return
        }
        let calibrationRequest = CalibrationRequest(profile_data: ProfileDataId(id: profileDataId))
        let operation = GetCalibrationOperation(session: session, calibrationRequest: calibrationRequest, handler: { [weak self] (calibration) in
            print("GetCalibrationOperation handler")
            guard let `self` = self, let calibration = calibration else {
                print("Error: calibration is nil")
                return
            }
            self.loadCalibrationFiles(calibration: calibration)
        })
        operationQueue.addOperation(operation)
    }
    
    private func loadCalibrationFiles(calibration: Calibration) {
        let operationX = LoadFileOperation(session: session, url: calibration.x_model_url) { (path, error) in
            print("LoadFileOperation handler")
            if let error = error {
                print("ERROR loadCalibrationFiles: \(error.localizedDescription)")
                return
            }
            guard let path = path else { return }
            DataManager.setXModelUrl(path)
            DataManager.status.value = DataStatus.loadingModelCompleted.rawValue
        }
        
        let operationY = LoadFileOperation(session: session, url: calibration.y_model_url) { (path, error) in
            print("LoadFileOperation handler")
            if let error = error {
                print("ERROR loadCalibrationFiles: \(error.localizedDescription)")
                return
            }
            guard let path = path else { return }
            DataManager.setYModelUrl(path)
            DataManager.status.value = DataStatus.loadingModelCompleted.rawValue
        }
        operationQueue.addOperation(operationX)
        operationQueue.addOperation(operationY)
    }
    
    func getCalibrationOrientation() -> String? {
        return profileData?.data.first?.calibrationData?.first?.deviceOrientation
    }

}

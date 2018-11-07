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
    
    override init() {
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
        let operation = UploadFileOperation(data: imageData, completionHandler: ({ (file) in
            guard let file = file else { return }
            print("UploadFileOperation completionBlock: \(file.url)")
            mutableCalibrationData.file = file
            self.calibrationDataArray.append(mutableCalibrationData)
        }))
        uploadFileQueue.addOperation(operation)
    }
    
    func preparePostProfileOperation() {
        let operation = NewPostProfileOperation(apiHelper: self, completionHandler: {profileData in
            print("PostProfileData success: \(profileData != nil)")
            self.profileData = profileData
            self.getCalibrations()
        })
        uploadFileQueue.operations.forEach{ operation.addDependency($0) }
        print("preparePostProfileOperation dependenciesCount: \(operation.dependencies.count)")
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
        let operation = NewGetCalibrationOperation(calibrationRequest: calibrationRequest, handler: { (calibration) in
            print("NewGetCalibrationOperation completionBlock")
            guard let calibration = calibration else {
                print("Error: calibration is nil")
                return
            }
            self.loadCalibrationFiles(calibration: calibration)
        })
        operationQueue.addOperation(operation)
    }
    
    private func loadCalibrationFiles(calibration: Calibration) {
        let operationX = LoadFileOperation(url: calibration.x_model_url) { (path, error) in
            print("LoadFileOperation.operationX completionBlock")
            if let error = error {
                print("ERROR loadCalibrationFiles: \(error.localizedDescription)")
                return
            }
            guard let path = path else { return }
            DataManager.setXModelUrl(path)
            DataManager.status.value = DataStatus.loadingModelCompleted.rawValue
        }
        
        let operationY = LoadFileOperation(url: calibration.y_model_url) { (path, error) in
            print("LoadFileOperation.operationY completionBlock")
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

//
//  RequestHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift
import CoreML

enum RequestStatus: Int {
    case notRequested = 10
    case requested = 20
    case failed = 30
    case completedMenuItems = 31
    case completedInputScreens = 32
    case completedLegalDocuments = 33
    case completed = 40
    case completedAcceptation = 50
    case completedFile = 60
    case completedProfileData = 70
    case completedCalibration = 80
}

// FIXME: RequestStatus should be updated to properly

class ApiRequestHandler {
    
    var status = Variable<Int>(0)
    
    fileprivate let config: URLSessionConfiguration
    fileprivate let session: URLSession
    
    fileprivate var menuItems: Array<MenuItem> = []
    fileprivate var inputScreens: Array<InputScreen> = []
    fileprivate var legalDocuments: Array<LegalDocument> = []
    fileprivate var acceptation: Acceptation?
    fileprivate var file: File?
    fileprivate var profileData: ProfileData?
    fileprivate var calibration: Calibration?
    fileprivate var model: MLModel?
    
    init() {
        config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        session = URLSession(configuration: config)
    }
    
    func requestMenuItems() {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_MENU_ITEMS) else { return }
        
        let task = self.session.dataTask(with: url) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }

            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }

            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Array<Any>) != nil else {
                print("Not containing JSON")
                return
            }

            do {
                self.menuItems = try JSONDecoder().decode([MenuItem].self, from: content)
                self.status.value = RequestStatus.completedMenuItems.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }

        task.resume()
    }
    
    func getMenuItems() -> Array<MenuItem> {
        return self.menuItems
    }
    
    func requestInputScreens() {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_INPUT_SCREENS) else { return }
        
        let task = self.session.dataTask(with: url) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Array<Any>) != nil else {
                print("Not containing JSON")
                return
            }
            
            do {
                self.inputScreens = try JSONDecoder().decode([InputScreen].self, from: content)
                self.status.value = RequestStatus.completedInputScreens.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }
        
        task.resume()
    }
    
    func getInputScreens() -> Array<InputScreen> {
        return inputScreens
    }
    
    
    func requestLegalDocuments() {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_LEGAL_DOCUMENTS) else { return }
        
        let task = self.session.dataTask(with: url) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Array<Any>) != nil else {
                print("Not containing JSON")
                return
            }
            
            do {
                self.legalDocuments = try JSONDecoder().decode([LegalDocument].self, from: content)
                self.status.value = RequestStatus.completedLegalDocuments.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }
        
        task.resume()
    }
    
    func getLegalDocuments() -> Array<LegalDocument> {
        return self.legalDocuments
    }
    
    func postAcceptation(acceptation: Acceptation) {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_LEGAL_ACCEPTATIONS) else { return }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(acceptation)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = self.session.dataTask(with: request) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any) != nil else {
                print("Not containing JSON")
                return
            }
            
            do {
                self.acceptation = try JSONDecoder().decode(Acceptation.self, from: content)
                self.status.value = RequestStatus.completedAcceptation.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }

        }
        
        task.resume()
    }
    
    func getAcceptation() -> Acceptation? {
        return self.acceptation
    }
    
    func uploadFile(data: Data) {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_FILES) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let task = self.session.uploadTask(with: request, from: data) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
           
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any) != nil else {
                print("Not containing JSON")
                return
            }
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            
            do {
                self.file = try JSONDecoder().decode(File.self, from: content)
//                print(self.file!)
                self.status.value = RequestStatus.completedFile.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }
        
        task.resume()
    }
    
    func getFile() -> File? {
        return self.file
    }
    
    func postProfileData(profileData: ProfileData) {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_PROFILE_DATAS) else { return }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(profileData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = self.session.dataTask(with: request) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any) != nil else {
                print("Not containing JSON")
                return
            }
            
            do {
                self.profileData = try JSONDecoder().decode(ProfileData.self, from: content)
//                print(self.profileData!)
                self.status.value = RequestStatus.completedProfileData.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }
        
        task.resume()
    }
    
    func getProfileData() -> ProfileData? {
        return self.profileData
    }
    
    func getCalibrations(calibrationRequest: CalibrationRequest) {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_CALIBRATIONS) else { return }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(calibrationRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = self.session.dataTask(with: request) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                self.status.value = RequestStatus.failed.rawValue
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.status.value = RequestStatus.failed.rawValue
                }
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any) != nil else {
                print("Not containing JSON")
                return
            }
            
            do {
                self.calibration = try JSONDecoder().decode(Calibration.self, from: content)
                print("Calibration: \(self.calibration!)")
                self.status.value = RequestStatus.completedCalibration.rawValue
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }
        
        task.resume()
    }
    
    func getCalibration() -> Calibration? {
        return self.calibration
    }
    
    func loadFileAsync(url: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: url) else { return }
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask (with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            
            task.resume()
        }
        
        // Comented by Rahman Mammadov
        
//        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let task = session.dataTask (with: request, completionHandler: { data, response, error in
//            if let error = error {
//                print("ERROR: loadFileAsync: \(error.localizedDescription)")
//                completion(destinationUrl.path, error)
//                return
//            }
//            guard
//                let response = response as? HTTPURLResponse,
//                let data = data,
//                response.statusCode == 200
//                else {
//                    completion(destinationUrl.path, error)
//                    return
//            }
//            do {
//                try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
//                completion(destinationUrl.path, error)
//            } catch let error {
//                completion(destinationUrl.path, error)
//            }
//        })
//        task.resume()
    }
}

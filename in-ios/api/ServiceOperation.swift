//
//  ServiceOperation.swift
//  in-ios
//
//  Created by Piotr Soboń on 06/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    private var backing_executing : Bool
    override var isExecuting : Bool {
        get { return backing_executing }
        set {
            willChangeValue(forKey: "isExecuting")
            backing_executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var backing_finished : Bool
    override var isFinished : Bool {
        get { return backing_finished }
        set {
            willChangeValue(forKey: "isFinished")
            backing_finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override init() {
        backing_executing = false
        backing_finished = false
        
        super.init()
    }
    
    func completeOperation() {
        isExecuting = false
        isFinished = true
    }
}

class UploadFileOperation: ConcurrentOperation {
    private var task: URLSessionUploadTask?
    
    private let data: Data
    private let completionHandler: ((File?) -> Void)
    
    init(data: Data, completionHandler: @escaping ((File?) -> Void)) {
        self.data = data
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_FILES)
            else {
            completeOperation()
            return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        
        let session = URLSession(configuration: config)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let task = session.uploadTask(with: urlRequest, from: data) { (data, response, error) in
            if let error = error {
                print("ERROR: UploadFileOperation error: \(error.localizedDescription)")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            
            guard let content = data else {
                print("No data")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            guard (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) != nil else {
                print("Not containing JSON")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            do {
                let file = try JSONDecoder().decode(File.self, from: content)
                self.completionHandler(file)
                self.completeOperation()
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
                self.completionHandler(nil)
                self.completeOperation()
            }
        }
        task.resume()
    }
}

class PostProfileOperation: ConcurrentOperation {
    private var task: URLSessionUploadTask?
    
    private let profileData: ProfileData
    private let requestHandler: ApiRequestHandler
    
    
    init(profileData: ProfileData, handler: ApiRequestHandler) {
        self.profileData = profileData
        self.requestHandler = handler
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_PROFILE_DATAS)
            else {
                completeOperation()
                return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        let session = URLSession(configuration: config)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(profileData)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: PostProfileOperation error: \(error.localizedDescription)")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.requestHandler.status.value = RequestStatus.failed.rawValue
                }
            }
            guard let content = data else {
                print("No data")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            guard (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) != nil else {
                print("Not containing JSON")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            do {
                self.requestHandler.profileData = try JSONDecoder().decode(ProfileData.self, from: content)
                self.requestHandler.status.value = RequestStatus.completedProfileData.rawValue
                self.completeOperation()
            } catch let jsonErr {
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                print("Error serializing json",  jsonErr)
                self.completeOperation()
            }
        }
        task.resume()
    }
}

class GetCalibrationOperation: ConcurrentOperation {
    private var task: URLSessionUploadTask?
    
    private let calibrationRequest: CalibrationRequest
    private let requestHandler: ApiRequestHandler
    
    
    init(calibrationRequest: CalibrationRequest, handler: ApiRequestHandler) {
        self.calibrationRequest = calibrationRequest
        self.requestHandler = handler
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_CALIBRATIONS)
            else {
                completeOperation()
                return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        let session = URLSession(configuration: config)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(calibrationRequest)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: GetCalibrationOperation error: \(error.localizedDescription)")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            
            // hanlde http response code
            if let httpResponse = response as? HTTPURLResponse {
                if  200 > httpResponse.statusCode || httpResponse.statusCode >= 300 {
                    self.requestHandler.status.value = RequestStatus.failed.rawValue
                }
            }
            guard let content = data else {
                print("No data")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            guard (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) != nil else {
                print("Not containing JSON")
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                self.completeOperation()
                return
            }
            do {
                self.requestHandler.calibration = try JSONDecoder().decode(Calibration.self, from: content)
                self.requestHandler.status.value = RequestStatus.completedCalibration.rawValue
                self.completeOperation()
            } catch let jsonErr {
                self.requestHandler.status.value = RequestStatus.failed.rawValue
                print("Error serializing json",  jsonErr)
                self.completeOperation()
            }
        }
        task.resume()
    }
}

class LoadFileOperation: ConcurrentOperation {
    private var task: URLSessionUploadTask?
    
    private let url: String
    private let completionHandler: ((String?, Error?) -> Void)
    
    init(url: String,  completion: @escaping (String?, Error?) -> Void) {
        self.url = url
        self.completionHandler = completion
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: url)
            else {
                completeOperation()
                return
        }
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        let session = URLSession(configuration: config)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: LoadFileOperation error: \(error.localizedDescription)")
                self.completionHandler(destinationUrl.path, error)
                self.completeOperation()
                return
            }
            guard let content = data else {
                print("No data")
                self.completionHandler(destinationUrl.path, error)
                self.completeOperation()
                return
            }
            do {
                try content.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                self.completionHandler(destinationUrl.path, error)
                self.completeOperation()
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
                self.completionHandler(destinationUrl.path, error)
                self.completeOperation()
            }
        }
        task.resume()
    }
}

class NewPostProfileOperation: ConcurrentOperation {
    typealias PostProfileOperationHandler = (ProfileData?) -> Void
    
    private let calibrationApiHelper: CalibrationApiHelper
    private let completionHandler: PostProfileOperationHandler
    
    init(apiHelper: CalibrationApiHelper, completionHandler: @escaping PostProfileOperationHandler) {
        self.calibrationApiHelper = apiHelper
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func main() {
        guard var user = DataManager.getUserData()
            else {
                print("ERROR: PreparePostProfileOperation")
                completeOperation()
                return
        }
        user.calibrationData = calibrationApiHelper.getCalibrationDataArray()
        //TODO: change FileNamingHelper method to static
        let deviceId = FileNamingHelper().getDeviiceUUID()
        let profileData = ProfileData(id: nil, version: 1, device_id: deviceId, data: [user])
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(profileData)
        let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_PROFILE_DATAS)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: PostProfileOperation error: \(error.localizedDescription)")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            guard let content = data else {
                print("ERROR: PostProfileOperation data is nil")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            guard let profileData = try? JSONDecoder().decode(ProfileData.self, from: content) else {
                print("ERROR: JSONSerialization error")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            self.completionHandler(profileData)
            self.completeOperation()
            
        }
        task.resume()
    }
}

class NewGetCalibrationOperation: ConcurrentOperation {
    typealias GetCalibrationHandler = ((Calibration?) -> Void)
    private var task: URLSessionUploadTask?
    
    private let calibrationRequest: CalibrationRequest
    private let completionHandler: GetCalibrationHandler
    
    
    init(calibrationRequest: CalibrationRequest, handler: @escaping GetCalibrationHandler) {
        self.calibrationRequest = calibrationRequest
        self.completionHandler = handler
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_CALIBRATIONS)
            else {
                completionHandler(nil)
                completeOperation()
                return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constant.DefaultConfig.TIMEOUT_FOR_REQUEST
        config.timeoutIntervalForResource = Constant.DefaultConfig.TIMEOUT_FOR_RESOURCE
        let session = URLSession(configuration: config)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(calibrationRequest)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: GetCalibrationOperation error: \(error.localizedDescription)")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            
            guard let content = data else {
                print("ERROR: GetCalibrationOperation data is nil")
                self.completionHandler(nil)
                self.completeOperation()
                return
            }
            
            do {
                let calibration = try JSONDecoder().decode(Calibration.self, from: content)
                self.completionHandler(calibration)
                self.completeOperation()
            } catch let jsonErr {
                print("ERROR: GetCalibrationOperation serialization: \(jsonErr.localizedDescription)")
                self.completionHandler(nil)
                self.completeOperation()
            }
        }
        task.resume()
    }
}

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
    private let session: URLSession
    
    init(session: URLSession, data: Data, completionHandler: @escaping ((File?) -> Void)) {
        self.data = data
        self.completionHandler = completionHandler
        self.session = session
        super.init()
    }
    
    override func main() {
        
        guard !isCancelled,
            let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_FILES)
            else {
            completeOperation()
            return
        }
        
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
                print("Not containing JSON: \(String(data: content, encoding: .utf8) ?? "-")")
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

class LoadFileOperation: ConcurrentOperation {
    private var task: URLSessionUploadTask?
    
    private let url: String
    private let completionHandler: ((String?, Error?) -> Void)
    private let session: URLSession
    
    init(session: URLSession, url: String,  completion: @escaping (String?, Error?) -> Void) {
        self.url = url
        self.completionHandler = completion
        self.session = session
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

class PostProfileOperation: ConcurrentOperation {
    typealias PostProfileOperationHandler = (ProfileData?) -> Void
    
    private let calibrationApiHelper: CalibrationApiHelper
    private let completionHandler: PostProfileOperationHandler
    private let session: URLSession
    
    init(session: URLSession, apiHelper: CalibrationApiHelper, completionHandler: @escaping PostProfileOperationHandler) {
        self.calibrationApiHelper = apiHelper
        self.completionHandler = completionHandler
        self.session = session
        super.init()
    }
    
    override func main() {
        guard var user = DataManager.getUserData()
            else {
                print("ERROR: PreparePostProfileOperation")
                completeOperation()
                return
        }
        let calibrationDataArray = calibrationApiHelper.getCalibrationDataArray()
        user.calibrationData = calibrationDataArray
        
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

class GetCalibrationOperation: ConcurrentOperation {
    typealias GetCalibrationHandler = ((Calibration?) -> Void)
    private var task: URLSessionUploadTask?
    
    private let calibrationRequest: CalibrationRequest
    private let completionHandler: GetCalibrationHandler
    private let session: URLSession
    
    init(session: URLSession, calibrationRequest: CalibrationRequest, handler: @escaping GetCalibrationHandler) {
        self.calibrationRequest = calibrationRequest
        self.completionHandler = handler
        self.session = session
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

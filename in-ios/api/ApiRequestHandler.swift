//
//  RequestHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

enum RequestStatus: Int {
    case notRequested = 10
    case requested = 20
    case failed = 30
    case completedMenuItems = 31
    case completedInputScreens = 32
    case completedLegalDocuments = 33
    case completed = 40
}

// FIXME: RequestStatus should be updated to properly

class ApiRequestHandler {
    
    var status = Variable<Int>(0)
    
    fileprivate let config: URLSessionConfiguration
    fileprivate let session: URLSession
    
    fileprivate var menuItems: Array<MenuItem> = []
    fileprivate var inputScreens: Array<InputScreen> = []
    fileprivate var legalDocuments: Array<LegalDocument> = []
    
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
    
    func postAcceptations(acceptation: Acceptation) {
        guard let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_LEGAL_ACCEPTATIONS) else { return }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(acceptation)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
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
            guard ((try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Array<Any>) != nil else {
                print("Not containing JSON")
                return
            }
        }
        
        task.resume()
    }
}

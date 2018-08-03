//
//  RequestHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

class ApiRequestHandler {
    
    var status = Variable<Int>(0)
    
    fileprivate let config: URLSessionConfiguration
    fileprivate let session: URLSession
    
    fileprivate var menuItems: Array<MenuItem>?
    
    init() {
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func requestMenuItems() {
        let url = URL(string: Constant.Url.HOST_API_BETA + Constant.Url.URL_EXTENSION_API + Constant.Url.URL_EXTENSION_MENU_ITEMS)!
        
        let task = self.session.dataTask(with: url) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
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
                self.status.value = 1
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }

        task.resume()
    }
    
    func getMenuItems() -> Array<MenuItem>? {
        return self.menuItems
    }
}

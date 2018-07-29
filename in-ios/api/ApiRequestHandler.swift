//
//  RequestHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class ApiRequestHandler {
    
    fileprivate let config: URLSessionConfiguration
    fileprivate let session: URLSession
    
    init() {
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func requestMenuItems() {
        let url = URL(string: Constant.url.HOST_API_BETA + Constant.url.URL_EXTENSION_API + Constant.url.URL_EXTENSION_MENU_ITEMS)!
        
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
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Array<Any> else {
                print("Not containing JSON")
                return
            }

            do {
                let menuItems = try JSONDecoder().decode([MenuItem].self, from: content)
                print(menuItems)
            } catch let jsonErr {
                print("Error serializing json",  jsonErr)
            }
        }

        task.resume()
    }
}

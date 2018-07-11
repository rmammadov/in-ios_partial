//
//  ReachabilityManager.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/11/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class ReachabilityManager: NSObject {
    
    static  let shared = ReachabilityManager()
    
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    var reachabilityStatus: Reachability.Connection = .none
    let reachability = Reachability()!
    
    // Called whenever there is a change in NetworkReachibility Status
    //
    // — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            debugPrint("Network became unreachable")
        case .wifi:
            debugPrint("Network reachable through WiFi")
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    // Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    // Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
}

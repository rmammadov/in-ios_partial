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

    var reachabilityStatus: Reachability.Connection = .none
    var isNetworkAvailable: Bool {
        return reachabilityStatus != .none
    }
    let reachability = Reachability()!
    
    // Called whenever there is a change in NetworkReachibility Status
    //
    // — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            debugPrint("Network became unreachable")
            reachabilityStatus = .none
        case .wifi:
            debugPrint("Network reachable through WiFi")
            reachabilityStatus = .wifi
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
            reachabilityStatus = .cellular
        }
    }
    
    // Starts monitoring the network availability status
    func startMonitoring() {
        reachabilityStatus = reachability.connection
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

}

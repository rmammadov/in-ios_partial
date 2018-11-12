//
//  UIViewControllerExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 12/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    @objc fileprivate func gazeTrackerUpdate(_ notification: Notification) {
        guard let gazeTrackerProtocol = self as? GazeTrackerUpdateProtocol,
            let coordinate = notification.userInfo?[NotificationKeys.UserInfo.kGazeTrackerCoordinate] as? CGPoint
            else {
                print("Error: GazeTrackerUpdate \(notification.debugDescription)")
                print("GazeTrackerUpdate: received notification but protocol not implemented or did not found coordinate")
            return
        }
        gazeTrackerProtocol.gazeTrackerUpdate(coordinate: coordinate)
    }
}

protocol GazeTrackerUpdateProtocol {
    func registerGazeTrackerObserver()
    func unregisterGazeTrackerObserver()
    func gazeTrackerUpdate(coordinate: CGPoint)
}

extension GazeTrackerUpdateProtocol where Self: UIViewController {
    func registerGazeTrackerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gazeTrackerUpdate(_:)),
                                               name: .GazeTrackerUpdateCoordinates,
                                               object: nil)
    }
    
    func unregisterGazeTrackerObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .GazeTrackerUpdateCoordinates,
                                                  object: nil)
    }
}

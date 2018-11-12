//
//  NotificationExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let ScreenTypeCClear = Notification.Name("notification.name.ScreenTypeCClear")
    public static let GazeTrackerUpdateCoordinates = Notification.Name("notification.name.GazeTrackerUpdateCoordinates")
}

struct NotificationKeys {
    struct UserInfo {
        public static let ParentViewController = "ParentViewController"
        public static let kGazeTrackerCoordinate = "GazeTrackerUpdateCoordinates.coordinates"
    }
}

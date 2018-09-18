//
//  FaceFinderDelegate.swift
//  INGazeTracking
//
//  Created by Alexandre Drouin-Picaro on 2018-08-10.
//  Copyright © 2018 innodem-neurosciences. All rights reserved.
//

import Foundation
import UIKit

protocol FaceFinderDelegate {
    func didFindFaces(status: Bool, scene: UIImage)
}

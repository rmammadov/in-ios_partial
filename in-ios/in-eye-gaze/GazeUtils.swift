//
//  GazeUtils.swift
//  in-ios
//
//  Created by Rahman Mammadov on 11/28/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import UIKit


class GazeUtils {
    
    //Width and height of the screen of various apple devices, in millimeters.
    let DEVICES = ["iPhone 6s":                 ["width": 58.0, "height": 100.0],
                   "iPhone 6s Plus":            ["width": 58.0, "height": 100.0],
                   "iPhone SE":                 ["width": 48.0, "height": 89.0],
                   "iPhone 7":                  ["width": 58.0, "height": 100.0],
                   "iPhone 7 Plus":             ["width": 58.0, "height": 100.0],
                   "iPhone 8":                  ["width": 58.0, "height": 100.0],
                   "iPhone 8 Plus":             ["width": 58.0, "height": 100.0],
                   "iPhone X":                  ["width": 62.0, "height": 135.0],
                   "iPad Air":                  ["width": 150.0, "height": 200.0],
                   "iPad Air 2":                ["width": 150.0, "height": 200.0],
                   "iPad 5":                    ["width": 150.0, "height": 200.0],
                   "iPad 6":                    ["width": 150.0, "height": 200.0],
                   "iPad Mini 2":               ["width": 120.0, "height": 160.0],
                   "iPad Mini 3":               ["width": 120.0, "height": 160.0],
                   "iPad Mini 4":               ["width": 120.0, "height": 160.0],
                   "iPad Pro 9.7 Inch":         ["width": 150.0, "height": 200.0],
                   "iPad Pro 12.9 Inch":        ["width": 198.0, "height": 264.0],
                   "iPad Pro 12.9 Inch 2":      ["width": 198.0, "height": 264.0],
                   "iPad Pro 10.5 Inch":        ["width": 162.0, "height": 216.0]]
    
    var deviceName: String = ""
    var screenWidthMil: Double = 0, screenHeightMil: Double = 0
    var screenWidthPix: Double = 0, screenHeightPix: Double = 0
    var PPCM: [Double] = [0.0, 0.0]
    
    init() {
        self.deviceName = UIDevice.current.modelName
        self.screenWidthMil = self.DEVICES[self.deviceName]!["width"]!
        self.screenHeightMil = self.DEVICES[self.deviceName]!["height"]!
        self.screenWidthPix = Double(UIScreen.main.fixedCoordinateSpace.bounds.size.width)
        self.screenHeightPix = Double(UIScreen.main.fixedCoordinateSpace.bounds.size.height)
        self.PPCM = [self.screenWidthPix/(self.screenWidthMil/10.0),
                     self.screenHeightPix/(self.screenHeightMil/10.0)]
    }
    
    static func deg2rad(degrees: Double) -> Double {return degrees * .pi / 180}
    
    static func rotateImage(image: UIImage, degrees: Double) -> UIImage? {
        if degrees == 0 { return image }
        
        guard let cgImage = image.cgImage else { return nil }
        
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(deg2rad(degrees: degrees)))
        rotatedViewBox.transform = t
        
        let newSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(newSize)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        //Rotate the image context
        context.rotate(by: CGFloat(deg2rad(degrees: degrees)))
        //Now, draw the rotated/scaled image into the context
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     Converts the coordinates of the gaze estimate from centimeters from the camera to pixels from screen center.
     
     - Parameter gazeX: the X position of the gaze as estimated by the model.
     - Parameter gazeY: the Y position of the gaze as estimated by the model.
     - Parameter camX: the horizontal position of the camera relative to the center of the device when in portrait mode, in centimeters.
     - Parameter camY: the vertical position of the camera relative to the center of the device when in portrait mode, in centimeters.
     - Parameter orientation: The current orientation of the device.
     */
    func cm2pixels(gazeX: Double, gazeY: Double, camX: Double, camY: Double, orientation: UIDeviceOrientation) -> (gazeX: Double, gazeY: Double) {
        
        var gazeXFromCenter: Double = 0, gazeYFromCenter: Double = 0 //Distance of gaze from center in centimenters
        var pixelsX: Double = 0, pixelsY: Double = 0 //Distance of gaze from center in pixels
        
        switch orientation {
        case .portraitUpsideDown:
            gazeXFromCenter = gazeX - camX
            gazeYFromCenter = gazeY - camY
            pixelsX = self.screenWidthPix/2 + Double(gazeXFromCenter * self.PPCM[0])
            pixelsY = self.screenHeightPix/2 - Double(gazeYFromCenter * self.PPCM[1])
        case .landscapeLeft:
            gazeXFromCenter = gazeX - camY
            gazeYFromCenter = gazeY + camX
            pixelsX = self.screenHeightPix/2 + Double(gazeXFromCenter * self.PPCM[1])
            pixelsY = self.screenWidthPix/2 - Double(gazeYFromCenter * self.PPCM[0])
        case .landscapeRight:
            gazeXFromCenter = gazeX + camY
            gazeYFromCenter = gazeY - camX
            pixelsX = self.screenHeightPix/2 + Double(gazeXFromCenter * self.PPCM[1])
            pixelsY = self.screenWidthPix/2 - Double(gazeYFromCenter * self.PPCM[0])
        default:
            gazeXFromCenter = gazeX + camX
            gazeYFromCenter = gazeY + camY
            pixelsX = self.screenWidthPix/2 + Double(gazeXFromCenter * self.PPCM[0])
            pixelsY = self.screenHeightPix/2 - Double(gazeYFromCenter * self.PPCM[1])
        }
        
        return (pixelsX, pixelsY)
    }
}

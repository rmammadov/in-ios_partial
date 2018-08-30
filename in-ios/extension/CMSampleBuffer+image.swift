//
//  CMSampleBuffer+image.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import AVFoundation

extension CMSampleBuffer {
    
    func image(orientation: UIImageOrientation = .up,
               scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            
            return UIImage(ciImage: ciImage,
                           scale: scale,
                           orientation: orientation)
        }
        
        return nil
    }
}

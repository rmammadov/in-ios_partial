//
//  UIImage+fixedOrientation.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIImage {
    
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
        transform = transform.translatedBy(x: size.width, y: size.height)
        transform = transform.rotated(by: CGFloat.pi)
        break
        case .left, .leftMirrored:
        transform = transform.translatedBy(x: size.width, y: 0)
        transform = transform.rotated(by: CGFloat.pi / 2.0)
        break
        case .right, .rightMirrored:
        transform = transform.translatedBy(x: 0, y: size.height)
        transform = transform.rotated(by: CGFloat.pi / -2.0)
        break
        case .up, .upMirrored:
        break
        }
        switch imageOrientation {
        case .upMirrored, .downMirrored:
        transform.translatedBy(x: size.width, y: 0)
        transform.scaledBy(x: -1, y: 1)
        break
        case .leftMirrored, .rightMirrored:
        transform.translatedBy(x: size.height, y: 0)
        transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
        break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
        ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
        ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

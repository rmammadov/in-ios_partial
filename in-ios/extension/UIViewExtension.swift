//
//  UIViewExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 10/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIView {
    
    func loadFromNib<T: UIView>() -> T {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: String(describing: self.classForCoder), bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? T else { fatalError("") }
        return view
    }
    
    func drawLine(from start: CGPoint, to end: CGPoint, color: UIColor = .white, width: CGFloat = 2) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        
        self.layer.addSublayer(shapeLayer)
    }
}


extension CGSize {
    var aspectRatio: CGFloat {
        return width / height
    }
}
extension UIImageView {
    
    func imageSizeAspectFit() -> CGSize? {
        guard let image = image else { return nil }
        let scale = min((bounds.width / image.size.width), (bounds.height/image.size.height))
        return CGSize(width: image.size.width * scale, height: image.size.height * scale)
    }
    
    func pointFrom(anchorCoords: CGPoint) -> CGPoint? {
        guard let image = self.image, let scalledImageSize = imageSizeAspectFit() else { return nil }
        let scale = scalledImageSize.height / image.size.height
        guard CGRect(origin: .zero, size: image.size).contains(anchorCoords) else { return nil }
        let dx = (bounds.size.width - scalledImageSize.width) / 2.0
        let dy = (bounds.size.height - scalledImageSize.height) / 2.0
        let point = CGPoint(x: (anchorCoords.x * scale) + dx, y: (anchorCoords.y * scale) + dy)
        return point
        
        
    }
}

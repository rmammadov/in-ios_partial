//
//  GradientView.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {

    @IBInspectable var mainColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var gradientColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isRounded: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = rect.size.height / 2.0
        layer.masksToBounds = true
        var gradient: CAGradientLayer
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradient = gradientLayer
        } else {
            gradient = CAGradientLayer()
        }
        guard let mainColor = mainColor else {
            gradient.removeFromSuperlayer()
            return
        }
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        var colors: [CGColor] = [mainColor.cgColor]
        if let gradientColor = self.gradientColor {
            colors.append(gradientColor.cgColor)
        } else {
            colors.append(mainColor.cgColor)
        }
        gradient.colors = colors
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
        print(rect)
    }

}

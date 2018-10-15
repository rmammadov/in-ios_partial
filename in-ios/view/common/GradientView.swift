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
    @IBInspectable var isRounded = true {
        didSet {
            setNeedsDisplay()
        }
    }
    var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet {
            setNeedsDisplay()
        }
    }
    var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// If lineWidth value is greater than 0 then this will be a gradient line not a full shape.
    var lineWidth: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var circleType: CircleType = .full {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isRounded {
            layer.cornerRadius = rect.size.height / 2.0
        }
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
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        var colors: [CGColor] = [mainColor.cgColor]
        if let gradientColor = self.gradientColor {
            colors.append(gradientColor.cgColor)
        } else {
            colors.append(mainColor.cgColor)
        }
        gradient.colors = colors
        
        if lineWidth > 0 {
            var outerBezierPath: UIBezierPath
            var innerBezierPath: UIBezierPath
            
            switch circleType {
            case .full:
                outerBezierPath = UIBezierPath(ovalIn: rect)
                innerBezierPath = UIBezierPath(ovalIn: rect.inset(by: UIEdgeInsets(top: lineWidth, left: lineWidth,
                                                                                   bottom: lineWidth, right: lineWidth)))
            case .halfLeft:
                let radius = min(bounds.width, bounds.height / 2.0)
                outerBezierPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.height / 2.0),
                                               radius: radius,
                                               startAngle: CGFloat.pi * -0.5,
                                               endAngle: CGFloat.pi * 0.5, clockwise: true)
                innerBezierPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.height / 2.0),
                                               radius: radius - lineWidth,
                                               startAngle: CGFloat.pi * -0.5,
                                               endAngle: CGFloat.pi * 0.5, clockwise: true)
            case .halfRight:
                let radius = min(bounds.width, bounds.height / 2.0)
                outerBezierPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width, y: bounds.height / 2.0),
                                               radius: radius,
                                               startAngle: CGFloat.pi * 0.5,
                                               endAngle: CGFloat.pi * 1.5, clockwise: true)
                innerBezierPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width, y: bounds.height / 2.0),
                                               radius: radius - lineWidth,
                                               startAngle: CGFloat.pi * 0.5,
                                               endAngle: CGFloat.pi * 1.5, clockwise: true)
            }
            outerBezierPath.close()
            innerBezierPath.close()
            
            outerBezierPath.append(innerBezierPath)
            outerBezierPath.usesEvenOddFillRule = true
            
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = .evenOdd
            maskLayer.path = outerBezierPath.cgPath
            gradient.mask = maskLayer
        } else {
            gradient.mask = nil
        }
        
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        } else {
            gradient.setNeedsDisplay()
        }
    }

}


enum CircleType {
    case full
    case halfLeft
    case halfRight
}

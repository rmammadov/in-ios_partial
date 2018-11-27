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
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var circleType: CircleType = .full {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var animateCompletionBlock: AnimateCompletionBlock?
    private var originDuration: CFTimeInterval = 0.0001
    
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


enum CircleType: Int {
    case full
    case halfLeft
    case halfRight
}


//MARK: - Animations

extension GradientView {
    func startAnimation(duration: CFTimeInterval, completion: @escaping AnimateCompletionBlock) {
        self.animateCompletionBlock = completion
        guard let mainColor = mainColor else { return }
        let selectionLineWidth: CGFloat = 5
        lineWidth = 1
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        var colors: [CGColor] = [mainColor.cgColor]
        if let gradientColor = self.gradientColor {
            colors.append(gradientColor.cgColor)
        } else {
            colors.append(mainColor.cgColor)
        }
        gradient.colors = colors
        
        let radius = (bounds.width - selectionLineWidth) / 2.0
        let center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        let thirdPath = UIBezierPath(arcCenter: center, radius: radius,
                                     startAngle: 0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = nil
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = selectionLineWidth
        maskLayer.path = thirdPath.cgPath
        gradient.mask = maskLayer
        
        originDuration = duration
        
        CATransaction.begin()
        
        if let animationLayer = layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.mask?.animation(forKey: "LoadingAnimation") != nil
        }), let oldAnimation = animationLayer.mask?.animation(forKey: "LoadingAnimation") as? CABasicAnimation {
            let startValue = oldAnimation.fromValue as! CFTimeInterval
            let animationTimeDuration = CACurrentMediaTime() - oldAnimation.beginTime
            let animationValue = ((originDuration * startValue) - animationTimeDuration) / originDuration
            let newAnimationDuration = originDuration - ((originDuration * startValue) - animationTimeDuration)
            let newAnimation = CABasicAnimation(keyPath: "strokeEnd")
            newAnimation.fromValue = animationValue
            newAnimation.toValue = 1
            newAnimation.duration = newAnimationDuration
            newAnimation.delegate = self
            animationLayer.mask?.add(newAnimation, forKey: "LoadingAnimation")
        } else {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = duration
            animation.delegate = self
            layer.addSublayer(gradient)
            maskLayer.add(animation, forKey: "LoadingAnimation")
        }
        
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        if let animationLayer = layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.mask?.animation(forKey: "LoadingAnimation") != nil
        }), let animation = animationLayer.mask?.animation(forKey: "LoadingAnimation") as? CABasicAnimation {
            let animationTimeDuration = (CACurrentMediaTime() - animation.beginTime)
            let animationValue = animationTimeDuration / originDuration
            animationLayer.mask?.removeAllAnimations()
            CATransaction.begin()
            let animationR = CABasicAnimation(keyPath: "strokeEnd")
            animationR.fromValue = animationValue
            animationR.toValue = 0
            animationR.duration = animationTimeDuration
            animationR.delegate = self
            (animationLayer.mask?.model()as? CAShapeLayer)?.strokeEnd = 0
            animationLayer.mask?.add(animationR, forKey: "LoadingAnimation")
            
            CATransaction.commit()
        } else {
            animateCompletionBlock?(false)
        }
    }
}

extension GradientView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag, let basicAnimation = (anim as? CABasicAnimation), basicAnimation.toValue as? Double ?? 0 == 0 {
            if layer.sublayers?.first(where: { $0.mask?.animationKeys() != nil }) == nil {
                layer.sublayers?.last?.removeFromSuperlayer()
            }
        }
        guard flag, let animation = anim as? CABasicAnimation else { return }
        let animationFinishValue = animation.toValue as? Double ?? 0
        self.animateCompletionBlock?(animationFinishValue  == 1)
        if let gradientLayer = layer.sublayers?.last {
            gradientLayer.removeFromSuperlayer()
        }
    }
}

//
//  GradientButton.swift
//  in-ios
//
//  Created by Piotr Soboń on 15/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class GradientButton: UIButton {
    private let kAnimationKey = "LoadingAnimation"
    @IBInspectable var mainColor: UIColor? { didSet { setNeedsDisplay() } }
    @IBInspectable var gradientColor: UIColor? { didSet { setNeedsDisplay() } }
    @IBInspectable var circleType: Int = CircleType.full.rawValue { didSet { setNeedsDisplay() } }
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable var selectionLineWidth: CGFloat = 5 { didSet { setNeedsDisplay() } }
    
    private var animateCompletionBlock: AnimateCompletionBlock?
    private var originDuration: CFTimeInterval = 0.0001
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let gradientLayer = prepareGradientLayer(width: lineWidth) else { return }
        layer.addSublayer(gradientLayer)
    }
    
    private func prepareGradientLayer(width: CGFloat) -> CALayer? {
        var gradient: CAGradientLayer
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradient = gradientLayer
        } else {
            gradient = CAGradientLayer()
        }
        guard let mainColor = mainColor else {
            gradient.removeFromSuperlayer()
            return nil
        }
        gradient.frame = bounds
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.colors = [mainColor.cgColor, gradientColor?.cgColor ?? mainColor.cgColor]
        
        var maskBezierPath: UIBezierPath
        switch CircleType(rawValue: circleType) {
        case .some(CircleType.full):
            let radius = (min(bounds.width, bounds.height) - width) / 2.0
            maskBezierPath = UIBezierPath(arcCenter: center, radius: radius,
                                          startAngle: 0, endAngle: CGFloat.pi * 2.0,
                                          clockwise: true)
        case .some(CircleType.halfLeft):
            let radius = min(bounds.height / 2.0, bounds.width) - (width / 2.0)
            maskBezierPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.height / 2.0), radius: radius,
                                          startAngle: CGFloat.pi * -0.5, endAngle: CGFloat.pi * 0.5,
                                          clockwise: true)
        case .some(CircleType.halfRight):
            let radius = min(bounds.height / 2.0, bounds.width) - (width / 2.0)
            maskBezierPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width, y: bounds.height / 2.0), radius: radius,
                                          startAngle: CGFloat.pi * -0.5, endAngle: CGFloat.pi * 0.5,
                                          clockwise: false)
        default: return nil
        }
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = nil
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = width
        maskLayer.path = maskBezierPath.cgPath
        gradient.mask = maskLayer
        return gradient
    }
    
}

// MARK: - AnimateObject methods

extension GradientButton: AnimateObject {
    func animateLoading(duration: CFTimeInterval, completionBlock: @escaping AnimateCompletionBlock) {
        animateCompletionBlock = completionBlock
        originDuration = duration
        CATransaction.begin()
        if let animationLayer = layer.sublayers?.first(where: { $0.mask?.animation(forKey: kAnimationKey) != nil }),
            let oldAnimation = animationLayer.mask?.animation(forKey: kAnimationKey) as? CABasicAnimation {
            let startValue = oldAnimation.fromValue as! Double
            let animationTimeDuration = CACurrentMediaTime() - oldAnimation.beginTime
            let animationValue = ((originDuration * startValue) - animationTimeDuration) / originDuration
            let newAnimationDuration = originDuration - ((originDuration * startValue) - animationTimeDuration)
            
            let newAnimation = CABasicAnimation(keyPath: "strokeEnd")
            newAnimation.fromValue = animationValue
            newAnimation.toValue = 1
            newAnimation.duration = newAnimationDuration
            newAnimation.delegate = self
            animationLayer.mask?.removeAllAnimations()
            animationLayer.mask?.add(newAnimation, forKey: kAnimationKey)
        } else {
            guard let gradientLayer = prepareGradientLayer(width: selectionLineWidth) else { return }
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = duration
            animation.delegate = self
            layer.addSublayer(gradientLayer)
            gradientLayer.mask?.add(animation, forKey: kAnimationKey)
        }
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        if let animationLayer = layer.sublayers?.first(where: { $0.mask?.animation(forKey: kAnimationKey) != nil }),
            let oldAnimation = animationLayer.mask?.animation(forKey: kAnimationKey) as? CABasicAnimation {
            guard oldAnimation.toValue as? Double != 0 else { return }
            let animationTimeDuration = CACurrentMediaTime() - oldAnimation.beginTime
            let animationValue = animationTimeDuration / originDuration
            animationLayer.mask?.removeAllAnimations()
            
            CATransaction.begin()
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = animationValue
            animation.toValue = 0
            animation.duration = animationTimeDuration
            animation.delegate = self
            (animationLayer.mask?.model() as? CAShapeLayer)?.strokeEnd = 0
            animationLayer.mask?.add(animation, forKey: kAnimationKey)
            CATransaction.commit()
        } else {
            animateCompletionBlock?(false)
        }
    }
    
    func setSelected(_ isSelected: Bool) {}
}

// MARK: - CAAnimationDelegate

extension GradientButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag, let animation = anim as? CABasicAnimation else { return }
        let animationFinishValue = animation.toValue as? Double ?? 0
        self.animateCompletionBlock?(animationFinishValue  == 1)
        if let gradientLayer = layer.sublayers?.last {
            gradientLayer.removeFromSuperlayer()
        }
    }
}

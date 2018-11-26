//
//  ProgressGradientView.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class ProgressGradientView: UIView {
    private let kAnimation = "ProgressGradientView.Animation"
    @IBInspectable var mainColor: UIColor = .appGradientBlue {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var gradientColor: UIColor = .appGradientViolet {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var animationCompletion: AnimateCompletionBlock?
    private var originDuration: CFTimeInterval = 0.001
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.backgroundColor = backgroundColor?.cgColor
        layer.cornerRadius = rect.size.height / 2.0
        layer.masksToBounds = true
    }
}

extension ProgressGradientView {
    func startAnimation(duration: CFTimeInterval, completion: @escaping AnimateCompletionBlock) {
        isHidden = false
        animationCompletion = completion
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.colors = [gradientColor.cgColor, mainColor.cgColor]
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: 0, y: bounds.height / 2.0))
        bezier.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = nil
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = bounds.height
        maskLayer.path = bezier.cgPath
        gradient.mask = maskLayer
        originDuration = duration
        
        CATransaction.begin()
        
        if let animationLayer = layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.mask?.animation(forKey: kAnimation) != nil
        }), let oldAnimation = animationLayer.mask?.animation(forKey: kAnimation) as? CABasicAnimation {
            let startValue = oldAnimation.fromValue as! CFTimeInterval
            let animationTimeDuration = CACurrentMediaTime() - oldAnimation.beginTime
            let animationValue = (((originDuration * startValue) - animationTimeDuration)) / originDuration
            let newAnimationDuration = originDuration - ((originDuration * startValue) - animationTimeDuration)
            let newAnimation = CABasicAnimation(keyPath: "strokeEnd")
            newAnimation.fromValue = animationValue
            newAnimation.toValue = 1
            newAnimation.duration = newAnimationDuration
            newAnimation.delegate = self
            animationLayer.mask?.add(newAnimation, forKey: kAnimation)
            isHidden = false
        } else {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = duration
            animation.delegate = self
            layer.addSublayer(gradient)
            maskLayer.add(animation, forKey: kAnimation)
        }
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        if let animationLayer = layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.mask?.animation(forKey: kAnimation) != nil
        }), let animation = animationLayer.mask?.animation(forKey: kAnimation) as? CABasicAnimation {
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
            animationLayer.mask?.add(animationR, forKey: kAnimation)
            
            CATransaction.commit()
        } else {
            animationCompletion?(false)
        }
    }
}

extension ProgressGradientView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag, let basicAnimation = (anim as? CABasicAnimation), basicAnimation.toValue as? Double ?? 0 == 0 {
            if layer.sublayers?.first(where: { $0.mask?.animationKeys() != nil }) == nil {
                self.isHidden = true
            }
        }
        guard flag, let animation = anim as? CABasicAnimation else { return }
        let animationFinishValue = animation.toValue as? Double ?? 0
        animationCompletion?(animationFinishValue == 1)
        if let gradientLayer = layer.sublayers?.last {
            gradientLayer.removeFromSuperlayer()
        }
    }
}

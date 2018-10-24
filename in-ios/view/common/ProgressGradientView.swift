//
//  ProgressGradientView.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class ProgressGradientView: UIView {
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
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.delegate = self
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            gradient.removeFromSuperlayer()
        }
        animation.delegate = self
        layer.addSublayer(gradient)
        
        maskLayer.add(animation, forKey: "LoadingAnimation")
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        layer.sublayers?.forEach({ (layer) in
            layer.mask?.removeAllAnimations()
        })
    }
}

extension ProgressGradientView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationCompletion?(flag)
    }
}

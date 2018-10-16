//
//  AnimationUtil.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum AnimationStatus: Int {
    case cancled = 0
    case completed = 1
}

enum AnimationDirection: Int {
    case left = 0
    case right = 1
}

class AnimationUtil {
    
    static var status = Variable<Int>(0)
    static var tag: String = " "
    
    static func animateMenuSelection(imageView: UIImageView?, fingerTouch: Bool, tag: String) {
        guard let imageView = imageView else { return }
        imageView.image = #imageLiteral(resourceName: "ic_circle_gradient_loading")
        self.tag = tag
        if fingerTouch {
            self.setMenuSelection(imageView: imageView)
            Timer.scheduledTimer(withTimeInterval: Constant.AnimationConfig.MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION, repeats: false) { (timer) in
                self.status.value += AnimationStatus.completed.rawValue
            }
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.setMenuSelection(imageView: imageView)
                self.status.value += AnimationStatus.completed.rawValue
            })
            let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
            rotationAnimation.duration = Constant.AnimationConfig.MENU_ITEM_ANIMATION_DURATION
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Constant.AnimationConfig.MENU_ITEM_ANIMATION_COUNT
            imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
            CATransaction.commit()
        }
    }

    static func setMenuSelection(imageView: UIImageView) {
         imageView.image = #imageLiteral(resourceName: "ic_circle_gradient_fill")
    }
    
    static func cancelMenuSelection(imageView: UIImageView) {
        imageView.layer.removeAllAnimations()
        imageView.image = #imageLiteral(resourceName: "ic_circle_gradient")
        self.status.value = AnimationStatus.cancled.rawValue
    }
    
    static func animateLoading(imageView: UIImageView) {
        imageView.image = #imageLiteral(resourceName: "ic_circle_gradient_loading")
    
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
        })
        let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
        rotationAnimation.duration = 0.5;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = .infinity;
        imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        CATransaction.commit()
    }
    
    static func animateMoving(view: UIView, direction: Int) {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        UIView.animate(withDuration: 4, animations: {
            switch(direction) {
            case AnimationDirection.right.rawValue:
                view.frame.origin.x = screenWidth - view.frame.origin.x - view.frame.width
            case AnimationDirection.left.rawValue:
                view.frame.origin.x = screenWidth - (view.frame.origin.x + view.frame.width)
            default:
                break
            }
        }) { finished in
            self.status.value += AnimationStatus.completed.rawValue
        }
    }
    
    static func getTag() -> String {
        return tag
    }
}

//New animation util methods

extension AnimationUtil {
    
    static func animateSelection(object: AnimateObject, fingerTouch: Bool, tag: String) {
        self.tag = tag
        if fingerTouch {
            object.setSelected(true)
            Timer.scheduledTimer(withTimeInterval: Constant.AnimationConfig.MENU_ITEM_FINGER_TOUCH_ANIMATION_DURATION, repeats: false) { (_) in
                self.status.value += AnimationStatus.completed.rawValue
            }
        } else {
            object.animateLoading { (isCompleted) in
                object.setSelected(true)
                self.status.value += AnimationStatus.completed.rawValue
            }
        }
    }
    
    static func cancelAnimation(object: AnimateObject) {
        object.cancelAnimation()
        object.setSelected(false)
        self.status.value = AnimationStatus.cancled.rawValue
    }
}

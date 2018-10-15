//
//  MenuItemCollectionViewCell.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gradientView: GradientView!
    
    public static let kLabelHeight: CGFloat = 38.5
    public static let kLabelSpacing: CGFloat = 7
   
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var ivStatusIcon: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareGradientView()
    }
    
    func setCell(url: String?, label: String?) {
        self.ivIcon.kf.indicatorType = .activity
        if let iconUrl = url {
            self.ivIcon.kf.setImage(with: URL(string: iconUrl))
        } else {
            self.ivIcon.kf.setImage(with: nil)
        }
        
        self.ivIcon.kf.indicatorType = .activity
        self.labelTitle.attributedText = attrubitedTextWithoutLineSpacing(text: label ?? "")
    }
    
    func prepareGradientView() {
        gradientView.mainColor = UIColor.appGradientBlue
        gradientView.gradientColor = UIColor.appGradientViolet
        gradientView.lineWidth = 1
        gradientView.startPoint = CGPoint(x: 0, y: 0)
        gradientView.endPoint = CGPoint(x: 1, y: 1)
        gradientView.circleType = .full
    }
    
    private func attrubitedTextWithoutLineSpacing(text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.78
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.avenirDemiBold(size: 18),
            .foregroundColor: UIColor.white
        ]
        let attrsString = NSAttributedString(string: text, attributes: attrs)
        return attrsString
    }
}

extension MenuItemCollectionViewCell: AnimateObject {
    func animateLoading(with completionBlock: @escaping (Bool) -> Void) {
        print("\(String(describing: self.self)): TODO: startAnimate")
        CATransaction.setCompletionBlock({
            completionBlock(true)
        })
        let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
        rotationAnimation.duration = Constant.AnimationConfig.MENU_ITEM_ANIMATION_DURATION
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Constant.AnimationConfig.MENU_ITEM_ANIMATION_COUNT
        gradientView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        gradientView.layer.removeAllAnimations()
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            gradientView.lineWidth = 0
            gradientView.setNeedsDisplay()
        } else {
            gradientView.lineWidth = 1
            gradientView.setNeedsDisplay()
        }
    }
}

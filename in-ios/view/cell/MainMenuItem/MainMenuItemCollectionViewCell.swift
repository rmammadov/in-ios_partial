//
//  MainMenuItemCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 12/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import Kingfisher

class MainMenuItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gradientCircle: GradientView!
    @IBOutlet weak var rightLabelContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientCircle.isRounded = true
        gradientCircle.mainColor = UIColor.appGradientBlue
        gradientCircle.gradientColor = UIColor.appGradientViolet
        gradientCircle.isHidden = true
        maximize(animated: false, toHeight: bounds.height)
    }
    
    func setupView(_ viewModel: ViewModel) {
        bottomTitleLabel.text = viewModel.title
        rightTitleLabel.text = viewModel.title
        if let urlString = viewModel.url {
            iconImageView.kf.indicatorType = .activity
            iconImageView.kf.setImage(with: URL(string: urlString))
        } else {
            iconImageView.image = nil
        }
    }
    
    func setSelected(_ isSelected: Bool) {
        highlightView.alpha = isSelected ? 1 : 0
        gradientCircle.isHidden = !isSelected
    }
    
    func minimize(animated: Bool = true, toHeight height: CGFloat) {
        let animationTime = animated ? 0.5 : 0.1
        bottomLabelContainerHeight.isActive = true
        rightLabelContainerWidth.isActive = false
        
        UIView.animate(withDuration: animationTime, animations: { [weak self] in
            guard let `self` = self else { return }
            self.layoutIfNeeded()
            self.animateCornerRadiusToSize(self.gradientCircle.bounds.size.height, duration: animationTime)
            self.gradientCircle.setNeedsDisplay()
            self.bottomTitleLabel.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.rightTitleLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: ({ (isCompleted) in
            print("minimize isCompleted: \(isCompleted)")
        }))
    }
    
    func maximize(animated: Bool = true, toHeight height: CGFloat) {
        let animationTime = animated ? 0.5 : 0.1
        bottomLabelContainerHeight.isActive = false
        rightLabelContainerWidth.isActive = true
        UIView.animate(withDuration: animationTime, animations: { [weak self] in
            guard let `self` = self else { return }
            self.layoutIfNeeded()
            self.animateCornerRadiusToSize(self.gradientCircle.bounds.size.height, duration: animationTime)
            self.bottomTitleLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.rightTitleLabel.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }, completion: ({ (isCompleted) in
                print("maximize isCompleted: \(isCompleted)")
                self.gradientCircle.setNeedsDisplay()
            }))
    }
    
    struct ViewModel {
        let title: String
        let url: String?
    }
    
    func animateCornerRadiusToSize(_ height: CGFloat, duration: Double) {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.duration = duration
        animation.fromValue = gradientCircle.layer.cornerRadius
        animation.toValue = height / 2.0
        animation.isRemovedOnCompletion = false
        gradientCircle.layer.add(animation, forKey: "setCornerRadius")
    }

}

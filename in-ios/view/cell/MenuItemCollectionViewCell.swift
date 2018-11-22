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
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
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
    func animateLoading(duration: CFTimeInterval, completionBlock: @escaping AnimateCompletionBlock) {
        gradientView.startAnimation(duration: duration, completion: completionBlock)
    }
    
    func cancelAnimation() {
        gradientView.cancelAnimation()
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

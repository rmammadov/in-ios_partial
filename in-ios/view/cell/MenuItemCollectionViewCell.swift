//
//  MenuItemCollectionViewCell.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
    
    public static let kLabelHeight: CGFloat = 38.5
    public static let kLabelSpacing: CGFloat = 7
   
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var ivStatusIcon: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    
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

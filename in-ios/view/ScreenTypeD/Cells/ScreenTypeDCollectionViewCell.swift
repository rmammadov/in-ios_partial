//
//  ScreenTypeDCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 11/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class ScreenTypeDCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientView.layer.cornerRadius = gradientView.bounds.height / 2.0
    }
    
    
    static func cellWidth(forText text: String) -> CGFloat {
        let font = UIFont.avenirDemiBold(size: 24)
        let string = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let rect = string.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: 44.0), options: [], context: nil)
        return rect.width + (2.0 * 28) + 1
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setSelected(_ isSelected: Bool) {
        gradientView.isHidden = !isSelected
    }

}

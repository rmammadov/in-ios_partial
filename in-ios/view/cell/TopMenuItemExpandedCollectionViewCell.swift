//
//  TopMenuItemExpandedCollectionViewCell.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class TopMenuItemExpandedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var ivStatusIcon: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var ivActiveLine: UIImageView!
    @IBOutlet weak var constraintTopMargin: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setIcon(url: String) {
        let url = URL(string: url)
        self.ivIcon.kf.indicatorType = .activity
        self.ivIcon.kf.setImage(with: url)
    }
    
    // TODO: Hardcode should be removed
    
    func setSelected(isSelected: Bool) {
        if isSelected {
            self.constraintTopMargin.constant = 12
            self.constraintBottomMargin.constant = 8
            self.ivActiveLine.isHidden = false
            self.ivStatusIcon.isHidden = false
        } else {
            self.constraintTopMargin.constant = 16
            self.constraintBottomMargin.constant = 12
            self.ivActiveLine.isHidden = true
            self.ivStatusIcon.isHidden = true
        }
    }
}

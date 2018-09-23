//
//  MenuItemCollectionViewCell.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var ivStatusIcon: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(url: String?, label: String?) {
        self.ivIcon.kf.indicatorType = .activity
        if let iconUrl = url {
            self.ivIcon.kf.setImage(with: URL(string: iconUrl))
        } else {
            self.ivIcon.kf.setImage(with: nil)
        }
        
        self.ivIcon.kf.indicatorType = .activity
        self.labelTitle.text = label
    }
}

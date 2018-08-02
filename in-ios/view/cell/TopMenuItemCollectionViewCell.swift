//
//  TopMenuItemCollectionViewCell.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/2/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class TopMenuItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelPassive: UILabel!
    @IBOutlet weak var viewActive: UIView!
    @IBOutlet weak var ivStatusIcon: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var labelActive: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

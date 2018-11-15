//
//  ScreenTypeHCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 24/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import Kingfisher

class ScreenTypeHCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var imageView: UIImageView!
    
    func setCell(url: String?) {
        imageView.kf.indicatorType = .activity
        if let iconUrl = url {
            imageView.kf.setImage(with: URL(string: iconUrl))
        } else {
            imageView.kf.setImage(with: nil)
        }
    }
}

extension ScreenTypeHCollectionViewCell: AnimateObject {
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

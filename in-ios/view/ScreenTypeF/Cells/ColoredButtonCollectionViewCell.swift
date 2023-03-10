//
//  ColoredButtonCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class ColoredButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var underlineProgressView: ProgressGradientView!
    @IBOutlet weak var backgroundLabelView: GradientView!
    
    private var viewModel: ViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLabelView.layer.cornerRadius = backgroundLabelView.frame.height / 2.0
    }
    
    struct ViewModel {
        let mainColor: UIColor
        let gradientColor: UIColor
        let translations: [Translation]
    }
    
    func setViewModel(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        colorView.backgroundColor = viewModel.mainColor
        titleLabel.text = viewModel.translations.currentTranslation()?.label
        underlineProgressView.mainColor = viewModel.gradientColor
        underlineProgressView.gradientColor = viewModel.mainColor
    }
}

extension ColoredButtonCollectionViewCell: AnimateObject {
    func animateLoading(duration: CFTimeInterval, completionBlock: @escaping AnimateCompletionBlock) {
        underlineProgressView.isHidden = false
        underlineProgressView.startAnimation(duration: duration) { [weak self] (isCompleted) in
            completionBlock(isCompleted)
            self?.underlineProgressView.isHidden = true
        }
    }
    
    func cancelAnimation() {
        underlineProgressView.cancelAnimation()
    }
    
    func setSelected(_ isSelected: Bool) {
        guard let viewModel = self.viewModel else { return }
        if isSelected {
            backgroundLabelView.mainColor = viewModel.mainColor
            backgroundLabelView.gradientColor = viewModel.mainColor
        } else {
            backgroundLabelView.mainColor = nil
        }
    }

}

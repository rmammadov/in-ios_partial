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
    @IBOutlet weak var underlineProgressView: UIView!
    @IBOutlet weak var backgroundLabelView: GradientView!
    
    private var viewModel: ViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        underlineProgressView.layer.cornerRadius = underlineProgressView.frame.height / 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLabelView.layer.cornerRadius = backgroundLabelView.frame.height / 2.0
    }
    
    struct ViewModel {
        let mainColor: UIColor
        let gradientColor: UIColor
        let translations: [TranslationMenuItem]
    }
    
    func setViewModel(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        colorView.backgroundColor = viewModel.mainColor
        titleLabel.text = viewModel.translations.first?.label
    }
    
    func setSelected(_ isSelected: Bool) {
        guard let viewModel = self.viewModel else { return }
        if isSelected {
            backgroundLabelView.mainColor = viewModel.mainColor
            backgroundLabelView.gradientColor = viewModel.gradientColor
        } else {
            backgroundLabelView.mainColor = nil
        }
    }

}

//
//  ScreenTypeCMenuCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 02/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class ScreenTypeCMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highlightedView: UIImageView!
    
    struct ViewModel {
        static private let titleMargin: CGFloat = 32.0
        var selectedTranslations: [TranslationMenuItem]?
        var translations: [TranslationInputScreen]
        
        var widthForCell: CGFloat {
            var text: String = ""
            if let selectedTranslations = selectedTranslations {
                text = selectedTranslations.first?.label ?? ""
            } else {
                text = translations.first?.title ?? ""
            }
            let font = UIFont.systemFont(ofSize: 34, weight: .bold)
            let string = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
            let rect = string.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: 100.0), options: [], context: nil)
            return rect.width + (2.0 * ViewModel.titleMargin) + 1
        }
    }
    
    func setViewModel(viewModel: ViewModel) {
        if let selectedTranslations = viewModel.selectedTranslations {
            titleLabel.text = selectedTranslations.first?.label
            titleLabel.textColor = .white
        } else {
            titleLabel.text = viewModel.translations.first?.title
            titleLabel.textColor = UIColor(named: "pigio_title_gray")!
        }
    }
    
    func setSelected(isSelected: Bool) {
        highlightedView.isHidden = !isSelected
    }
}

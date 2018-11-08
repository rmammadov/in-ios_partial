//
//  ScreenTypeGCollectionViewCell.swift
//  in-ios
//
//  Created by Piotr Soboń on 23/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class ScreenTypeGCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var progressView: ProgressGradientView!
    
    var viewModel: ViewModel! {
        didSet {
            setupView(viewModel: viewModel)
        }
    }
    
    private func setupView(viewModel: ViewModel) {
        titleLabel.text = viewModel.translations.currentTranslation()?.label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.setNeedsDisplay()
    }
    
    struct ViewModel {
        let translations: [Translation]
    }

}

extension ScreenTypeGCollectionViewCell: AnimateObject {
    func animateLoading(duration: CFTimeInterval, completionBlock: @escaping AnimateCompletionBlock) {
        progressView.isHidden = false
        progressView.startAnimation(duration: duration) { [weak self] (isCompleted) in
            completionBlock(isCompleted)
            if isCompleted {
                self?.progressView.isHidden = true
            }
        }
    }
    
    func cancelAnimation() {
        progressView.isHidden = true
        progressView.cancelAnimation()
    }
    
    func setSelected(_ isSelected: Bool) {
        gradientView.isHidden = !isSelected
    }
    
}

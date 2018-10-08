//
//  ProgressGradientView.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class ProgressGradientView: UIProgressView {
    @IBInspectable var mainColor: UIColor = .black {
        didSet {
            setupProgressView()
        }
    }
    @IBInspectable var gradientColor: UIColor = .blue{
        didSet {
            setupProgressView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        transform = CGAffineTransform(scaleX: -1, y: -1)
    }
    
    private func setupProgressView() {
        progressTintColor = backgroundColor
        let gradientView = GradientView(frame: bounds)
        gradientView.mainColor = gradientColor
        gradientView.gradientColor = mainColor
        let gradientImage = UIImage(view: gradientView)
        trackImage = gradientImage
    }
    
    override func setProgress(_ progress: Float, animated: Bool) {
        let invertedValue = 1.0 - progress
        super.setProgress(invertedValue, animated: animated)
    }
}

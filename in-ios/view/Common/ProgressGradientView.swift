//
//  ProgressGradientView.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

@IBDesignable class ProgressGradientView: UIProgressView {
    @IBInspectable var mainColor: UIColor = .appGradientBlue {
        didSet {
            setupProgressView()
        }
    }
    @IBInspectable var gradientColor: UIColor = .appGradientViolet {
        didSet {
            setupProgressView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        transform = CGAffineTransform(scaleX: -1, y: -1)
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    private func setupProgressView() {
        progressTintColor = #colorLiteral(red: 0.4196078431, green: 0.4196078431, blue: 0.4196078431, alpha: 1)
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

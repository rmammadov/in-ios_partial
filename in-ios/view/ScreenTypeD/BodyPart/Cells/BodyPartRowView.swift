//
//  BodyPartRowView.swift
//  in-ios
//
//  Created by Piotr Soboń on 09/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class BodyPartRowView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var progressView: ProgressGradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    
    var titleAlignment: NSTextAlignment = .right {
        didSet {
            titleTrailingConstraint.isActive = titleAlignment == .left
            titleLeadingConstraint.isActive = titleAlignment != .left
        }
    }
    
    var bubble: Bubble? {
        didSet {
            guard let bubble = bubble else { return }
            setupView(with: bubble)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layer.cornerRadius = gradientView.bounds.height / 2.0
    }
    
    private func xibSetup() {
        view = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadFromNib() -> UIView {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: String(describing: self.classForCoder), bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else { fatalError("") }
        return view
    }
    
    private func setupView(with bubble: Bubble) {
        titleLabel.text = bubble.translations.first?.label
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

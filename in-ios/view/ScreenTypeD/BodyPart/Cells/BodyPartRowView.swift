//
//  BodyPartRowView.swift
//  in-ios
//
//  Created by Piotr Soboń on 09/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

protocol BodyPartRowDelegate: class {
    func didSelect(_ row: BodyPartRowView, bubble: Bubble)
}

class BodyPartRowView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var progressView: ProgressGradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: BodyPartRowDelegate?
    
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
    
    private func setupView(with bubble: Bubble) {
        titleLabel.text = bubble.translations.first?.label
    }

    @IBAction func buttonTapped(_ sender: Any) {
        guard let bubble = self.bubble else { return }
        delegate?.didSelect(self, bubble: bubble)
    }
    
    func setSelected(_ isSelected: Bool) {
        gradientView.isHidden = !isSelected
    }
}

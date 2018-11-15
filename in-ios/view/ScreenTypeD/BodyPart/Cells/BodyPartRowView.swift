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
    @IBOutlet weak var newProgressView: ProgressGradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: BodyPartRowDelegate?
    
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
        titleLabel.text = bubble.translations.currentTranslation()?.label
    }

    @IBAction func buttonTapped(_ sender: Any) {
        guard let bubble = self.bubble else { return }
        delegate?.didSelect(self, bubble: bubble)
    }
}

extension BodyPartRowView: AnimateObject {
    func animateLoading(duration: CFTimeInterval, completionBlock: @escaping AnimateCompletionBlock) {
        newProgressView.isHidden = false
        newProgressView.startAnimation(duration: duration) { [weak self] (isCompleted) in
            completionBlock(isCompleted)
            self?.newProgressView.isHidden = true
        }
    }
    
    func cancelAnimation() {
        newProgressView.cancelAnimation()
    }
    
    func setSelected(_ isSelected: Bool) {
        gradientView.isHidden = !isSelected
    }
    
}

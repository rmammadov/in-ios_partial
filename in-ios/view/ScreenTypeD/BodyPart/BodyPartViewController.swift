//
//  BodyPartViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

let kMaxRowHeight: CGFloat = 80

class BodyPartViewController: BaseViewController {
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var viewModel = BodyPartViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareArrowLines()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.prepareArrowLines()
        }
        
    }
    
}

extension BodyPartViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        setupUI()
    }
    
    private func setupUI() {
        if let imageUrl = viewModel.getImageUrl() {
            KingfisherManager.shared.retrieveImage(with: imageUrl, options: nil, progressBlock: nil) { [weak self] (image, error, cache, url) in
                guard let `self` = self else { return }
                self.mainImageView.image = image
                self.prepareArrowLines()
            }
        }
        prepareBodyPartsButtons()
        setSubscribers()
    }
    
    private func prepareBodyPartsButtons() {
        leftStackView.removeAllSubviews()
        rightStackView.removeAllSubviews()
        let items = viewModel.getItems()
        let numberOfLines = items.count / 2 + items.count % 2
        var itemHeight = view.bounds.height / CGFloat(numberOfLines)
        if itemHeight > kMaxRowHeight { itemHeight = kMaxRowHeight }
        var frame = CGRect(origin: .zero,
                           size: CGSize(width: leftStackView.bounds.width,
                                        height: itemHeight))
        for (index, item) in items.enumerated() {
            frame.origin.y = CGFloat(index / 2) * itemHeight
            let row = BodyPartRowView(frame: frame)
            row.titleAlignment = (index % 2 == 0) ? .left : .right
            row.bubble = item
            row.delegate = self
            row.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
            if index % 2 == 0 {
                leftStackView.addArrangedSubview(row)
            } else {
                rightStackView.addArrangedSubview(row)
            }
        }
        
    }
    
    private func prepareArrowLines() {
        mainImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        leftStackView.arrangedSubviews.forEach { (view) in
            guard
                let row = view as? BodyPartRowView,
                let anchorCoord = row.bubble?.anchorCords,
                let imageCoord = mainImageView.pointFrom(anchorCoords: anchorCoord)
                else { return }
            let convertedRect = self.view.convert(row.frame, from: leftStackView)
            let x: CGFloat = 0
            let y: CGFloat = convertedRect.origin.y + (convertedRect.size.height / 2.0)
            let start = CGPoint(x: x, y: y)
            mainImageView.drawLine(from: start, to: imageCoord)
        }
        
        rightStackView.arrangedSubviews.forEach { (view) in
            guard
                let row = view as? BodyPartRowView,
                let anchorCoord = row.bubble?.anchorCords,
                let imageCoord = mainImageView.pointFrom(anchorCoords: anchorCoord)
                else { return }
            let convertedRect = self.view.convert(row.frame, from: rightStackView)
            let x: CGFloat = mainImageView.bounds.width
            let y: CGFloat = convertedRect.origin.y + (convertedRect.size.height / 2.0)
            let start = CGPoint(x: x, y: y)
            mainImageView.drawLine(from: start, to: imageCoord)
        }
    }
    
    private func setSubscribers() {
        viewModel.getSelectedBubbleObservable().subscribe(onNext: { [weak self] (bubble) in
            guard let `self` = self else { return }
            self.select(bubble: bubble, in: self.leftStackView)
            self.select(bubble: bubble, in: self.rightStackView)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onParentClearSelection(notification:)),
                                               name: Notification.Name.ScreenTypeCClear, object: nil)
    }
    
    @objc func onParentClearSelection(notification: Notification) {
        viewModel.setSelectedBubble(nil)
    }
    
    private func select(bubble: Bubble?, in stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { (view) in
            if let row = view as? BodyPartRowView {
                if let bubble = bubble {
                    row.setSelected(row.bubble?.translations.first?.label == bubble.translations.first?.label)
                } else {
                    row.setSelected(false)
                }
            }
        }
    }
}

extension BodyPartViewController: BodyPartRowDelegate {
    func didSelect(_ row: BodyPartRowView, bubble: Bubble) {
        viewModel.setSelectedBubble(bubble)
    }
}

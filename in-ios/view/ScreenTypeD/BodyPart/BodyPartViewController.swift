//
//  BodyPartViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

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
    
}

extension BodyPartViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        prepareBodyPartsButtons()
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
            row.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
            if index % 2 == 0 {
                leftStackView.addArrangedSubview(row)
            } else {
                rightStackView.addArrangedSubview(row)
            }
        }
        
    }
    
    private func prepareArrowLines() {
        leftStackView.arrangedSubviews.forEach { (view) in
            guard let row = view as? BodyPartRowView else { return }
            print(row.convert(leftStackView.frame, to: view))
        }
    }
}

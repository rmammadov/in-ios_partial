//
//  UIStackViewExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 09/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIStackView {
    func removeAllSubviews() {
        let views = arrangedSubviews
        views.forEach { (view) in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

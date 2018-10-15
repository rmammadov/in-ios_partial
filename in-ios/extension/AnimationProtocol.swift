//
//  AnimationProtocol.swift
//  in-ios
//
//  Created by Piotr Soboń on 15/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
typealias AnimateCompletionBlock = ((Bool) -> Void)
protocol AnimateObject {
    func animateLoading(with completionBlock: @escaping AnimateCompletionBlock)
    func cancelAnimation()
    func setSelected(_ isSelected: Bool)
}

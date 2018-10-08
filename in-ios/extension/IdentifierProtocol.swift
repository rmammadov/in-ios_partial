//
//  IdentifierProtocol.swift
//  in-ios
//
//  Created by Piotr Soboń on 03/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

protocol Identifier {}

extension Identifier {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
}
extension UITableViewCell: Identifier {}
extension UIViewController: Identifier {}
extension UICollectionViewCell: Identifier {}

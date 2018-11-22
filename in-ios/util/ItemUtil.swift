//
//  ItemUtil.swift
//  in-ios
//
//  Created by Piotr Soboń on 30/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import UIKit

class ItemUtil {
    static let shared = ItemUtil()
    private let settings = SettingsHelper.shared
    
    private init() {
    }
    
    func getItemSize(withTitle: Bool = true) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let containerSize = CGSize(width: screenSize.width - (Constant.kLeadingMargin + Constant.kTrailingMargin),
                                   height: screenSize.height - (Constant.kTopMargin + Constant.kBottomMargin + Constant.kMenuSmallSize))
        var itemWidth = (containerSize.width - (Constant.kItemMargin * CGFloat(getColumnCount() - 1))) / CGFloat(getColumnCount())
        let itemHeight = containerSize.height / CGFloat(getRowCount()) - ((withTitle) ? 0 : Constant.kItemLabelSpace)
        if itemWidth > itemHeight {
            itemWidth = itemHeight - (withTitle ? Constant.kItemLabelSpace : 0)
        }
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func getColumnCount() -> Int {
        let orientation = UIDevice.current.orientation
        switch settings.tileSize {
        case .small:
            return orientation.isLandscape ? 7 : 5
        case .large:
            return orientation.isLandscape ? 5 : 4
        }
    }
    
    func getRowCount() -> Int {
        let orientation = UIDevice.current.orientation
        switch settings.tileSize {
        case .small:
            return orientation.isLandscape ? 5 : 7
        case .large:
            return orientation.isLandscape ? 4 : 5
        }
    }
    
    
    struct Constant {
        static let kMenuLargeSize: CGFloat = 116
        static let kMenuSmallSize: CGFloat = 64
        static let kTopMargin: CGFloat = 16
        static let kBottomMargin: CGFloat = 16
        static let kLeadingMargin: CGFloat = 65
        static let kTrailingMargin: CGFloat = 65
        static let kItemMargin: CGFloat = 16
        static let kItemLabelSpace: CGFloat = 45.5
        struct Normal {
            static let kRowCount = 4
            static let kColumnCount = 5
        }
    }
    
}

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
    
    private init() {
    }
    
    func getItemSize(withTitle: Bool = true) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let containerSize = CGSize(width: screenSize.width - (Constant.kLeadingMargin + Constant.kTrailingMargin),
                                   height: screenSize.height - (Constant.kTopMargin + Constant.kBottomMargin + Constant.kMenuSmallSize))
        var itemWidth = (containerSize.width - (Constant.kItemMargin * CGFloat(Constant.Normal.kColumnCount - 1))) / CGFloat(Constant.Normal.kColumnCount)
        let itemHeight = containerSize.height / CGFloat(Constant.Normal.kRowCount) - ((withTitle) ? 0 : Constant.kItemLabelSpace)
        if itemWidth > itemHeight {
            itemWidth = itemHeight - (withTitle ? Constant.kItemLabelSpace : 0)
        }
        print(itemHeight)
        return CGSize(width: itemWidth, height: itemHeight)
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

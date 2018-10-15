//
//  UIColorExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var appGradientBlue: UIColor { return #colorLiteral(red: 0.2588235294, green: 0.8196078431, blue: 1, alpha: 1) }
    
    static var appGradientViolet: UIColor { return #colorLiteral(red: 0.5215686275, green: 0.06274509804, blue: 0.8196078431, alpha: 1) }
    
    static var appHighlightBlue: UIColor { return #colorLiteral(red: 0.2392156863, green: 0.5490196078, blue: 1, alpha: 1) }
    
    static var appGray: UIColor { return #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1) }
    
    convenience init?(hex: String) {
        var string: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if string.hasPrefix("#") { string.remove(at: string.startIndex) }
        
        guard string.count == 6 || string.count == 8 else { return nil }
        
        var rgbValue: UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)
        
        switch string.count {
        case 6:
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: 1.0)
        case 8:
            self.init(red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
                      alpha: CGFloat((rgbValue & 0xFF000000) >> 32) / 255.0)
        default: return nil
        }
    }
}

//
//  UnderlinePagerOptions.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/11/19.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import Swift_PageMenu

struct UnderlinePagerOption: PageMenuOptions {

    var isInfinite: Bool = false

    var menuItemSize: PageMenuItemSize {
        return .sizeToFit(minWidth: 80, height: 30)
    }
    
    var menuTitleColor: UIColor {
        return .black
    }
    
    var menuTitleSelectedColor: UIColor {
        return .black
    }
    
    var menuCursor: PageMenuCursor {
        return .underline(barColor: .black, height: 2)
    }

    var font: UIFont {
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    
    var menuItemMargin: CGFloat {
        return 8
    }
    
    var tabMenuBackgroundColor: UIColor {
        return .black
    }
    
    public init(isInfinite: Bool = false) {
        self.isInfinite = isInfinite
    }
}

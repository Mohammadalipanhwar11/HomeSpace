//
//  RoundRectPageOptions.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/11/19.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import Swift_PageMenu

struct RoundRectPagerOption: PageMenuOptions {

    var isInfinite: Bool = false

    var tabMenuPosition: TabMenuPosition = .top

    var menuItemSize: PageMenuItemSize {
        return .sizeToFit(minWidth: 80, height: 60)
    }

    var menuTitleColor: UIColor {
        return UIColor(red: 43/255, green: 152/255, blue: 240/255, alpha: 1.0)
    }

    var menuTitleSelectedColor: UIColor {
        return .white
    }

    var menuCursor: PageMenuCursor {
        return .roundRect(rectColor: .black, cornerRadius: 10, height: 42, borderWidth: nil, borderColor: nil)
    }

    var font: UIFont {
        return UIFont.systemFont(ofSize: 30)
    }

    var menuItemMargin: CGFloat {
        return 8
    }

    var tabMenuBackgroundColor: UIColor {
        return Theme.mainColor
    }

    var tabMenuContentInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }

    public init(isInfinite: Bool = false, tabMenuPosition: TabMenuPosition = .top) {
        self.isInfinite = isInfinite
        self.tabMenuPosition = tabMenuPosition
    }
}

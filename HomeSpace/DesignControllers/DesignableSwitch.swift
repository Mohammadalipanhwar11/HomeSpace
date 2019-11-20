//
//  DesignableSwitch.swift
//  HomeSpace
//
//  Created by Kashif Rizwan on 10/25/19.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class DesignableSwitch: UISwitch {

    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }

}

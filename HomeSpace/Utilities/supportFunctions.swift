//
//  supportFunctions.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/5/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import Foundation
import UIKit

class supportFunctions
{
    func setCornerRadius(button:UIButton)
    {
        let height = button.frame.height
        button.layer.cornerRadius = height/2
    }
    
    func getBottomLine(textField:UITextField)
    {
        textField.addLine(position: .LINE_POSITION_BOTTOM, color: UIColor(displayP3Red: 43/255, green: 152/255, blue: 240/255, alpha: 1), width: 1)
    }
    
    func getBottomLineBtn(button:UIButton)
    {
        button.addLine(position: .LINE_POSITION_BOTTOM, color: UIColor(displayP3Red: 43/255, green: 152/255, blue: 240/255, alpha: 1), width: 1)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 10
    }
    
    func confirmationAlert()
    {
        
    }
}


//
//  extensions.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/6/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import Foundation
import UIKit

enum LINE_POSITION
{
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UIView {
    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}

extension UITextField
{
    func  charactersLimit(count:Int) {

        if (self.text!.count > count) {
            self.deleteBackward()
        }
    }
}

extension UIViewController
{
    func alert(msg:String , controller:UIViewController, textField:UITextField)
    {
        let alertValidation = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "Okay", style: .default)
        {
            (_) in textField.becomeFirstResponder()
        }
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
    }
    
    func confirmationAlert(msg:String , controller:UIViewController)
    {
        let alertValidation = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
    }
    
    func confirmationAlert2(msg:String , controller:UIViewController)
    {
        let alertValidation = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "Okay", style: .default)
        { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
    }
    
    func logoutAlert(msg:String , controller:UIViewController)
    {
        let alertValidation = UIAlertController(title: "Success", message: msg, preferredStyle: .alert)
        let buttonNo = UIAlertAction(title: "No", style: .default, handler: nil)
        let buttonOK = UIAlertAction(title: "Yes", style: .default)
        { (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertValidation.addAction(buttonNo)
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
    }
    
    func successAlert(msg:String , controller:UIViewController)
    {
        let alertValidation = UIAlertController(title: "Success", message: msg, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "Okay", style: .default)
        { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
        
    }
    
    func successAlert(title:String, msg:String , controller:UIViewController)
    {
        let alertValidation = UIAlertController(title: "\(title)", message: msg, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "Okay", style: .default)
        { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alertValidation.addAction(buttonOK)
        present(alertValidation, animated: true, completion: nil)
        
    }
//    func alertSegue(msg:String , controller:UIViewController)
//    {
//        let alertValidation = UIAlertController(title: "Welcome", message: msg, preferredStyle: .alert)
//        let buttonOK = UIAlertAction(title: "Okay", style: .default, handler: {_ in self.performSegue(withIdentifier: "loginScreen", sender: self) })
//        alertValidation.addAction(buttonOK)
//        present(alertValidation, animated: true, completion: nil)
//    }
}


//
//  PhoneLoginVC.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/5/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import MBProgressHUD

class PhoneLoginVC: UIViewController
{


    //MARK: -Constants
    let userService = userFunctions()
    let support = supportFunctions()
     
     //MARK: -Variables
    var countryCode = ""
    var number = ""
     
     //MARK: -Outlets
    @IBOutlet weak var phoneNum: FPNTextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    
     //MARK: -Actions
     
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func phoneLogin(_ sender: UIButton)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if phoneNum.text?.isEmpty == true
        {
            MBProgressHUD.hide(for: self.view, animated: true)
            alert(msg: "Phone Number Missing", controller: self, textField: phoneNum)
        }
        else if phoneNum.getRawPhoneNumber() == nil
        {
            self.confirmationAlert(msg: "Phone Number Entered is Invalid or Incorrect", controller: self)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        else
        {
            fpnDidValidatePhoneNumber(textField: phoneNum, isValid: true)
            userService.phoneAuth(PhoneNo: number)
            MBProgressHUD.hide(for: self.view, animated: true)
            performSegue(withIdentifier: "codeVerification", sender: self)
        }
    }
    
    
    //MARK: -Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        phoneNum.text = ""
        doneBtn.isEnabled = false
        phoneNum.charactersLimit(count: 15)
    }
    
    override func viewDidLayoutSubviews()
    {
        phoneNum.flagButtonSize = CGSize(width: 40, height: 40)
        phoneNum.charactersLimit(count: 15)
        support.getBottomLine(textField: phoneNum)
        support.setCornerRadius(button: doneBtn)
    }
    
    func changePlaceholderColor()
    {
        var placeHolder = NSMutableAttributedString()
        let Name = phoneNum.placeholder!
        phoneNum.flagButtonSize = CGSize(width: 40, height: 40)
    
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string:Name, attributes: [NSAttributedString.Key.font:UIFont(name: "Ubuntu", size: 15.0)!])

        // Set the color
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range:NSRange(location:0,length:Name.count))

        // Add attribute
        phoneNum.attributedPlaceholder = placeHolder
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        changePlaceholderColor()
        self.phoneNum.textColor = .white
        phoneNum.delegate = self
    }
}

extension PhoneLoginVC: FPNTextFieldDelegate
{
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool)
    {
        if isValid
        {
            let num = phoneNum.getFormattedPhoneNumber(format: .E164)
            number = num!
        }
        else
        {
            print("Invalid Number")
        }
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String)
    {
        print(name, dialCode, code) // Output "Pakistan", "+92", "PK"
        countryCode = dialCode
    }
}

extension PhoneLoginVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let text = (phoneNum.text! as NSString).replacingCharacters(in: range, with: string)
        
        if text.isEmpty
        {
            doneBtn.isEnabled = false
        }
        else if text.count >= 10
        {
            doneBtn.isEnabled = true
        }
        else if text.count < 10
        {
            doneBtn.isEnabled = false
        }

        return true
    }
}

//
//  EmailLoginVC.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/5/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import MBProgressHUD

class EmailLoginVC: UIViewController {
    
    //MARK: -Constants
    let userService = userFunctions()
    let support = supportFunctions()
       
    //MARK: -Variables
       
    //MARK: -Outlets
    
    @IBOutlet weak var forgotPw: UIButton!
    @IBOutlet weak var email: JVFloatLabeledTextField!
    @IBOutlet weak var password: JVFloatLabeledTextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    //MARK: -Actions
    
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login(_ sender: UIButton)
    {
        if email.text?.isEmpty == true
        {
            alert(msg: "Email Missing", controller: self, textField: email)
            email.becomeFirstResponder()
        }
        else if password.text?.isEmpty == true
        {
            alert(msg: "Password Missing", controller: self, textField: password)
            password.becomeFirstResponder()
        }
        else
        {
            login()
        }
    }
    
    
    //MARK: -Functions
    
    func login()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        userService.login(email: email.text!, password: password.text!)
                   {
                       (user, error, success) in
                       if error != nil
                       {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.confirmationAlert(msg: error!, controller: self)
                       }
                       else
                       {
           //                self.userName.text = ""
           //                self.password.text = ""
                           guard let success = success else { return }
                           
                           if success == true
                           {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.performSegue(withIdentifier: "emailLogin", sender: self)
                           }
                       }
                   }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews()
    {
        support.getBottomLine(textField: email)
        support.getBottomLine(textField: password)
        support.setCornerRadius(button: loginBtn)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

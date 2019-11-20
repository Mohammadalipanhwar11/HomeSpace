//
//  NewSignUpVC.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/5/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import MBProgressHUD
import FirebaseAuth

class NewSignUpVC: UIViewController {

    //MARK: -Constants
    let delegate     = UIApplication.shared.delegate as! AppDelegate
    let support      = supportFunctions()
    let userServices = userFunctions()
    
    //MARK: -Variables
    
    //MARK: -Outlets
    
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var firstName: JVFloatLabeledTextField!
    @IBOutlet weak var lastName: JVFloatLabeledTextField!
    @IBOutlet weak var email: JVFloatLabeledTextField!
    @IBOutlet weak var password: JVFloatLabeledTextField!
    @IBOutlet weak var phoneNo: JVFloatLabeledTextField!
    
    
    //MARK: -Actions
    
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAccount(_ sender: UIButton)
    {
        if firstName.text?.isEmpty == true
        {
            alert(msg: "First Name Missing", controller: self, textField: firstName)
        }
        else if lastName.text?.isEmpty == true
        {
            alert(msg: "Last Name Missing", controller: self, textField: lastName)
        }
        else if password.text?.isEmpty == true
        {
            alert(msg: "Password Missing", controller: self, textField: password)
        }
        else if email.text?.isEmpty == true
        {
            alert(msg: "Email Missing", controller: self, textField: email)
        }
        else if phoneNo.text?.isEmpty == true
        {
            alert(msg: "Phone Number Missing", controller: self, textField: phoneNo)
        }
        else
        {
            createUser()
        }
    }
    
    
    //MARK: -Functions
    
    func createUser()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let user1 = User(uid: nil, firstName: firstName.text!, lastName: lastName.text!, email: email.text!, password: password.text!, phoneNo: Int(phoneNo.text!))
        
        userServices.createUser(user: user1)
        {
            (authError ,user, success, error ) in
            if let err = error
            {
                self.confirmationAlert(msg: err, controller: self)
            }
            
            guard let user = user else
            {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.confirmationAlert(msg: authError!, controller: self)
                return
            }
            self.delegate.currentUser = user
            let uid = Auth.auth().currentUser?.uid
            
            let g = Group(name: "Archive", date: Date(), uid: uid!)
            taskManager.shared.createGroup(group: g, completion: { (flag) in
                let g = Group(name: "Home", date: Date(), uid: uid!)
                taskManager.shared.createGroup(group: g, completion: { (flag) in
                    let g = Group(name: "Personal", date: Date(), uid: uid!)
                    taskManager.shared.createGroup(group: g, completion: { (flag) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.performSegue(withIdentifier: "signUp", sender: self)
                    })
                })
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews()
    {
        support.setCornerRadius(button: createAccountBtn)
        support.getBottomLine(textField: firstName)
        support.getBottomLine(textField: lastName)
        support.getBottomLine(textField: email)
        support.getBottomLine(textField: password)
        support.getBottomLine(textField: phoneNo)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }


}

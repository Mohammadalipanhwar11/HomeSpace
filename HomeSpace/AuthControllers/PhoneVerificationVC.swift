//
//  PhoneVerificationVC.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/5/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import FirebaseFirestore

class PhoneVerificationVC: UIViewController {

   //MARK: -Constants
    let support = supportFunctions()
    let infoText = """
We've sent you a text message with a verification code.
Enter it here.
"""
    
    //MARK: -Variables
    
    //MARK: -Outlets
    @IBOutlet weak var verificationCodeTxt: UITextField!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var verifyBtn: UIButton!
    
    
    //MARK: -Actions
    
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func phoneLogin(_ sender: UIButton)
    {
        if verificationCodeTxt.text?.isEmpty == true
        {
            print("Enter Verification Code")
            alert(msg: "Verification Code Missing", controller: self, textField: verificationCodeTxt)
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
        
        var verificationID = ""
        if let vrID = UserDefaults.standard.string(forKey: "authVerificationID"){
            verificationID = vrID
        }
        
        let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationID,
        verificationCode: "\(verificationCodeTxt.text!)")
        
        Auth.auth().signIn(with: credential)
        {
            (result, error) in
            
            if let err = error
            {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(err.localizedDescription)
                self.verificationCodeTxt.text = ""
                self.confirmationAlert(msg: err.localizedDescription, controller: self)
                return
            }
            
            print("User Signed In")
            
            let uid = Auth.auth().currentUser?.uid
            
            Firestore.firestore().collection("groups").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if snapshot!.isEmpty{
                    let g = Group(name: "Archive", date: Date(), uid: uid!)
                    taskManager.shared.createGroup(group: g, completion: { (flag) in
                        let g = Group(name: "Home", date: Date(), uid: uid!)
                        taskManager.shared.createGroup(group: g, completion: { (flag) in
                            let g = Group(name: "Personal", date: Date(), uid: uid!)
                            taskManager.shared.createGroup(group: g, completion: { (flag) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.performSegue(withIdentifier: "phoneLogin", sender: self)
                            })
                        })
                    })
                }else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.performSegue(withIdentifier: "phoneLogin", sender: self)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        verificationCodeTxt.text = ""
        verificationCodeTxt.becomeFirstResponder()
        verifyBtn.isEnabled = false
    }
    
    override func viewDidLayoutSubviews()
    {
        verificationCodeTxt.charactersLimit(count: 6)
        support.getBottomLine(textField: verificationCodeTxt)
        support.setCornerRadius(button: verifyBtn)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        infoLbl.text = infoText
        verificationCodeTxt.delegate = self
    }
}

extension PhoneVerificationVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let text = (verificationCodeTxt.text! as NSString).replacingCharacters(in: range, with: string)
        
        if text.isEmpty
        {
            verifyBtn.isEnabled = false
        }
        else if text.count >= 6
        {
            verifyBtn.isEnabled = true
        }
        else if text.count < 6
        {
            verifyBtn.isEnabled = false
        }

        return true
    }
}

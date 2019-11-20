//
//  editGroupViewController.swift
//  HomeSpace
//
//  Created by Axiom123 on 01/08/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class editGroupViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var editTextField: UITextField!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var group:Group?
        var previosVC:LIstOfGroupsViewController!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.editTextField.text = self.group?.name
         if self.editTextField.text == "Home" || self.editTextField.text == "Archive" || self.editTextField.text == "Personal"{
            self.editTextField.isEnabled = false
        }
        self.doneButton.cornerRadius = doneButton.frame.height/2
        editTextField.becomeFirstResponder()
        self.editTextField.cornerRadius = editTextField.frame.height/2
        NotificationCenter.default.addObserver(self, selector: #selector(editGroupViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editGroupViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        _ = keyboardSize.cgRectValue
        print(keyboardSize.cgRectValue)
        self.bottomConstraint.constant = -keyboardSize.cgRectValue.height
        
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard notification.userInfo != nil else {return}
        bottomConstraint.constant = 0
        
    }

    @IBAction func deleteGroup(_ sender: Any) {
        if self.editTextField.text == "Home" || self.editTextField.text == "Archive" || self.editTextField.text == "Personal"{
            successAlert(title: "Message", msg: "Home, Archive and Personal cannot be deleted.", controller: self)
        }else{
            let alert = UIAlertController(title: nil, message: "Are you sure you want to delete group?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                taskManager.shared.deleteGroup(group: self.group!) { (flag) in
                    self.dismiss(animated: true, completion: self.previosVC.goBack)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        if self.editTextField.text == ""{
            successAlert(title: "message", msg: "Group name should not be empty", controller: self)
        }else{
            self.group?.name = self.editTextField.text!
            taskManager.shared.editGroup(group: self.group!) { (flag) in
                self.dismiss(animated: true, completion: self.previosVC.goBack)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

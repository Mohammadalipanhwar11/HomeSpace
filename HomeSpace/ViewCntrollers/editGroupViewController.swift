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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        bottomConstraint.constant = keyboardSize.cgPointValue.y / -1.6
        
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard notification.userInfo != nil else {return}
        bottomConstraint.constant = 0
        
    }
    
    

    @IBAction func deleteGroup(_ sender: Any) {
        taskManager.shared.deleteGroup(Name: "khk") { (err) in
            
        }
    }
    @IBAction func done(_ sender: Any) {
    }
    @IBAction func back(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

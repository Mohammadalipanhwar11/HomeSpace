//
//  editTaskViewController.swift
//  HomeSpace
//
//  Created by axom1234 on 20/05/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class editTaskViewController: UIViewController {

    var text:String?
    var key1:String?
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var toolsBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.editText.text = text
        NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        _ = keyboardSize.cgRectValue
        print(keyboardSize.cgRectValue)
        toolsBottomConstraint.constant = keyboardSize.cgPointValue.y / -1.6
        
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard notification.userInfo != nil else {return}
        toolsBottomConstraint.constant = 0
        
    }
    @IBAction func back(_ sender: Any) {
                        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func done(_ sender: Any) {

        
        taskManager.shared.updateText(key: key1!, updatedRank: self.editText.text!) { (err) in
            
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
    
}

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
    var groupID: String?
    var deleteID: String?
    var deleteTitle: String?
    var reminder: String?
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var remiderLabel: UILabel!
    @IBOutlet weak var toolsBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if reminder != "" {
            setButton.setTitle("Change", for: UIControl.State.normal)
        }else{
            setButton.setTitle("Set", for: UIControl.State.normal)

        }
        
        remiderLabel.text = "Reminder: \(reminder!)"
        setButton.cornerRadius = setButton.frame.height/2.5
        moveButton.cornerRadius = moveButton.frame.height/2.5
        archiveButton.cornerRadius = archiveButton.frame.height/2.5
        deleteButton.cornerRadius = archiveButton.frame.height/2.5
        
        
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
        moveButton.isHidden = true
        archiveButton.isHidden = true
        
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard notification.userInfo != nil else {return}
        toolsBottomConstraint.constant = 0
        moveButton.isHidden = false
        archiveButton.isHidden = false
    }
    @IBAction func back(_ sender: Any) {
                        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func done(_ sender: Any) {

        
        taskManager.shared.updateText(key: key1!, updatedRank: self.editText.text!, group: self.groupID!) { (err) in
            
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    
    @IBAction func archive(_ sender: Any) {
        taskManager.shared.deleteTask(key: self.deleteID!, group: self.deleteTitle!) { (err) in
        }
        let t = Task(name: editText.text!, date: Date(), group: "Archive")
        taskManager.shared.addTask(task: t) { (err) in
            
        }
        performSegue(withIdentifier: "tovc", sender: self)
    }
    
    @IBAction func move(_ sender: Any) {
        performSegue(withIdentifier: "move", sender: self)
    }
    
    @IBAction func set(_ sender: Any) {
        self.performSegue(withIdentifier: "Date", sender: self)

    }
    
    @IBAction func delete1(_ sender: Any) {
        taskManager.shared.deleteTask(key: deleteID!, group: groupID!) { (err) in
            
        }
        _ = navigationController?.popViewController(animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "move"{
            let dest = segue.destination as! moveGroupViewController
            dest.groupText = editText.text
            dest.deleteID = deleteID
            dest.deleteTitle = deleteTitle
        }else if segue.identifier == "Date"{
            let dest = segue.destination as! ReminderViewController
            dest.text = self.editText.text
            dest.groupID = self.groupID
            dest.TaskID = self.deleteID
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
        if segue.source is ReminderViewController {
            if let senderVC = segue.source as? ReminderViewController {
                setButton.setTitle("Change", for: .normal)
                
                self.remiderLabel.text = "Reminder: \(senderVC.reminderDate ?? "")"
            }
        }
        
    }
    
    
}

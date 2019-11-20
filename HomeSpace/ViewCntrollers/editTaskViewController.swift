//
//  editTaskViewController.swift
//  HomeSpace
//
//  Created by axom1234 on 20/05/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import FirebaseAuth

class editTaskViewController: UIViewController {
    
    var text:String?
    var key1:String?
    var groupID: String?
    var deleteID: String?
    var deleteTitle: String?
    var reminder: String?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var remiderLabel: UILabel!
    @IBOutlet weak var toolsBottomConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            var dict = dict
            if let grpName = dict["openGroup"]{
                dict["openGroup"] = ""
                UserDefaults.standard.set(dict, forKey: "dict")
            }
        }
        
        if reminder != "" {
            setButton.setTitle("Change", for: UIControl.State.normal)
        }else{
            setButton.setTitle("Set", for: UIControl.State.normal)
            
        }
        
        remiderLabel.text = "Reminder: \(reminder!)"
        setButton.cornerRadius = setButton.frame.height * 0.1
        moveButton.cornerRadius = moveButton.frame.height * 0.1
        archiveButton.cornerRadius = archiveButton.frame.height * 0.1
        deleteButton.cornerRadius = archiveButton.frame.height * 0.1
        
        
        self.editText.text = text
        NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        _ = keyboardSize.cgRectValue
        print(keyboardSize.cgRectValue.height)
        toolsBottomConstraint.constant = keyboardSize.cgRectValue.height
//                moveButton.isHidden = true
//                archiveButton.isHidden = true
        
        
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
        let archiveGroup = Task.sharedSearch.firstIndex(where: {$0.group.name == "Archive"})
        print(Task.sharedSearch[archiveGroup!].group)
        let t = Task(name: self.editText.text!, date: Date(), group: Task.sharedSearch[archiveGroup!].group.id!, uid: Auth.auth().currentUser!.uid)
        taskManager.shared.addTask(task: t) { (err) in }
        taskManager.shared.deleteTask(key: self.deleteID!) { (err) in}
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func move(_ sender: Any) {
        performSegue(withIdentifier: "move", sender: self)
    }
    
    @IBAction func set(_ sender: Any) {
        self.performSegue(withIdentifier: "Date", sender: self)
        
    }
    
    @IBAction func delete1(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            taskManager.shared.deleteTask(key: self.deleteID!) { (err) in
            }
            _ = self.navigationController?.popViewController(animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
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

//
//  ReminderViewController.swift
//  HomeSpace
//
//  Created by Axiom123 on 31/07/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications


class ReminderViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var doneButton: UIButton!
    
    let notifications = "Reminder"
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var text:String?
    var groupID: String?
    var TaskID: String?
    var reminderDate:String?
    var uid:String!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doneButton.cornerRadius = self.doneButton.frame.height/2
        
        let now = Date()
        pickerView.minimumDate = now
        self.textView.text = text

        pickerView.setValue(UIColor.white, forKeyPath: "textColor")

        self.switchView.isOn = true
        pickerView.isUserInteractionEnabled = true

    }
    
    @IBAction func picker(_ sender: Any) {
        

    }
    
    @IBAction func `switch`(_ sender: Any) {
        if self.switchView.isOn == false{
            pickerView.isUserInteractionEnabled = false
        }else if switchView.isOn{
            pickerView.isUserInteractionEnabled = true
            
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        // convert to Integer
        
        self.appDelegate?.scheduleNotification(notificationType: notifications, time: self.pickerView.date, body: self.textView.text,groupID: self.groupID!, taskID: self.TaskID!, UID: "1")
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: pickerView.date)
        reminderDate = strDate
        
        taskManager.shared.updateReminder(key: TaskID!, group: groupID!, reminder: strDate) { (err) in
            
        }
        
        if switchView.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in /* do nothing*/
            }
        }
        
                let controllers = self.navigationController?.viewControllers    
        if let cont = controllers![controllers!.count-3] as? PageTabMenuViewController{
            self.navigationController?.popToViewController(cont, animated: true)
        }

    }
    
    @IBAction func back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

}

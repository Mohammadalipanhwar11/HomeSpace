//
//  moveGroupViewController.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import CodableFirebase
import FirebaseAuth

class moveGroupViewController: UIViewController {
    
    
    var groupItems = [Group](){
        didSet {
            TableView.reloadData()
        }
    }
    
    @IBOutlet weak var TableView: UITableView!
    
    
    @IBOutlet weak var createGroupButton: UIButton!
    var textData:String?
    var segue:Bool?
    var groupText: String?
    var deleteID:String?
    var deleteTitle:String?
    var groupName:String?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskManager.shared.getAllGroup { (gArr, err) in
            self.groupItems = gArr
        }
        TableView.delegate = self
        TableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func cellButtonAction(_ sender: UIButton) {
        
        sender.layer.borderColor = UIColor.orange.cgColor
        sender.titleLabel?.textColor = UIColor.orange
        if segue == false {
            print(Auth.auth().currentUser!.uid)
            let t = Task(name: textData!, date: Date(), group: self.groupItems[sender.tag].id!, uid: Auth.auth().currentUser!.uid)
            taskManager.shared.addTask(task:t) { (err) in }
            let controllers = self.navigationController?.viewControllers
            if let cont = controllers![1] as? PageTabMenuViewController{
                self.navigationController?.popToViewController(cont, animated: true)
                
            }
        }else {
            taskManager.shared.deleteTask(key: self.deleteID!) { (err) in}
            let t = Task(name: self.groupText!, date: Date(), group: self.groupItems[sender.tag].id!, uid: Auth.auth().currentUser!.uid)
                           taskManager.shared.addTask(task: t) { (err) in }
            let controllers = self.navigationController?.viewControllers
            if let cont = controllers![1] as? PageTabMenuViewController{
                self.navigationController?.popToViewController(cont, animated: true)
            }
            
            
        }
    }
    
    
    @IBAction func createGroup(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "newgroup", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newgroup" {
            let dest = segue.destination as! NewGroupViewController
            if self.textData != nil{
                dest.taskText = self.textData
            }else if self.groupText != nil{
                dest.taskText = self.groupText
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension moveGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groups") as! groupsTableViewCell
        cell.groupItem.addTarget(self, action: #selector(cellButtonAction(_:)), for: .touchUpInside)
        cell.groupItem.setTitle(groupItems[indexPath.row].name, for: .normal)
        cell.groupItem.tag = indexPath.row
        cell.groupItem.layer.cornerRadius = 26
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupItems.count
    }
}

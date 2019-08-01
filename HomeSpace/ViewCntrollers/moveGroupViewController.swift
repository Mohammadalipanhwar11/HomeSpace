//
//  moveGroupViewController.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import FirebaseFirestore

class moveGroupViewController: UIViewController {
    
    
    var groupItems = [String](){
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Firestore.firestore().collection("tasks")
            .getDocuments { (snap, err) in
                snap?.documentChanges.forEach({ (group) in
                    print(group.document.documentID)
                    let arr = group.document.documentID
                    self.groupItems.append(arr)
                    
                })
        }
        TableView.delegate = self
        TableView.dataSource = self
        
        createGroupButton.layer.cornerRadius = createGroupButton.frame.height/2
        
    }
    

 
    

    @objc func cellButtonAction(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
        sender.layer.borderColor = UIColor.orange.cgColor
        sender.titleLabel?.textColor = UIColor.orange
        if segue == false {
            let t = Task(name: textData!, date: Date(), group: (sender.titleLabel?.text!)!)
            taskManager.shared.addTask(task:t) { (err) in
                
            }
        }else {
            taskManager.shared.deleteTask(key: self.deleteID!, group: self.deleteTitle!) { (err) in
            }
            let t = Task(name: groupText!, date: Date(), group: sender.titleLabel!.text!)
            taskManager.shared.addTask(task: t) { (err) in
                
            }
        }
    }
    
    
    @IBAction func createGroup(_ sender: Any) {
        performSegue(withIdentifier: "newgroup", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {

        if segue.source is NewGroupViewController {
            if let senderVC = segue.source as? NewGroupViewController {
                
                self.groupItems.append(senderVC.groupText!)
                
            }
        }
        
    }
    
    
    
    
}


extension moveGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groups") as! groupsTableViewCell
        
        cell.groupItem.layer.cornerRadius = cell.groupItem.frame.height/2
        cell.groupItem.addTarget(self, action: #selector(cellButtonAction(_:)), for: .touchUpInside)
        cell.groupItem.setTitle(groupItems[indexPath.row], for: .normal)
        return cell

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

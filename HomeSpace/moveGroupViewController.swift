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
    
    
    let groupItems = ["New","Today","Tomorrow", "Archive", "Later-Family", "Later-Work", "Later-Misc"]
    @IBOutlet weak var TableView: UITableView!

    
    var textData:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        
        
    }
    

 
    

    @objc func cellButtonAction(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
        sender.layer.borderColor = UIColor.orange.cgColor
        sender.titleLabel?.textColor = UIColor.orange
        let t = Task(name: textData!, date: "\(Date())")
        taskManager.shared.addTask(task:t) { (err) in
            
        }
    }
    
    
    
}


extension moveGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groups") as! groupsTableViewCell
        
        cell.groupItem.layer.cornerRadius = cell.groupItem.frame.height/2
        if indexPath.row == 0 {
            cell.groupItem.addTarget(self, action: #selector(cellButtonAction(_:)), for: .touchUpInside)
            cell.groupItem.setTitle(groupItems[0], for: .normal)
        }else if indexPath.row == 1{
            cell.groupItem.setTitle(groupItems[1], for: .normal)
        }else if indexPath.row == 2{
            cell.groupItem.setTitle(groupItems[2], for: .normal)
        }else if indexPath.row == 3{
            cell.groupItem.setTitle(groupItems[3], for: .normal)
        }else if indexPath.row == 4{
            cell.groupItem.setTitle(groupItems[4], for: .normal)
        }else if indexPath.row == 5{
            cell.groupItem.setTitle(groupItems[5], for: .normal)
        }else if indexPath.row == 6{
            cell.groupItem.setTitle(groupItems[6], for: .normal)
        }
        
        
        
        return cell

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupItems.count
    }
}

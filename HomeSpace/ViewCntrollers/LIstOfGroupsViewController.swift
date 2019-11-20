//
//  LIstOfGroupsViewController.swift
//  HomeSpace
//
//  Created by Admin on 26/09/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class LIstOfGroupsViewController: UIViewController {
    @IBOutlet weak var groupTable: UITableView!
    
    var groupItems = [Group](){
        didSet {
            self.groupTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            var dict = dict
            if let _ = dict["openGroup"]{
                dict["openGroup"] = ""
                UserDefaults.standard.set(dict, forKey: "dict")
            }
        }
        
        
        taskManager.shared.getAllGroup { (gArr, err) in
            self.groupItems = gArr
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goBack(){
        self.dismiss(animated: false, completion: nil)
    }
}


extension LIstOfGroupsViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groups") as! GroupTableViewCell
        cell.groupItem.setTitle(self.groupItems[indexPath.row].name!, for: .normal)
        cell.groupItem.addTarget(self, action: #selector(selectGroup), for: .touchUpInside)
        cell.groupItem.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupItems.count
    }
    
    @objc func selectGroup(sender:UIButton){
        let cont = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editGroup") as! editGroupViewController
        cont.previosVC = self    
        cont.group = self.groupItems[sender.tag]
        self.present(cont, animated: true, completion: nil)
    }
}

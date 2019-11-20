//
//  popOverViewController.swift
//  HomeSpace
//
//  Created by Axiom123 on 26/08/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol popoverDelegate {
    func selectedItem(index:Int)->Void
}

class popOverViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var popDelegate:popoverDelegate?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var group:Group?
    
    let emailItems = ["Group","Change Password","Logout"]
    let phoneItems = ["Group","Logout"]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! popOverTableViewCell
//        cell.Groups.text = self.items[indexPath.row]
        
        if Auth.auth().currentUser?.email == nil
        {
            cell.Groups.text = self.phoneItems[indexPath.row]
            if indexPath.row == 1
            {
                cell.Groups.textColor = .red
            }
        }
        else
        {
            cell.Groups.text = self.emailItems[indexPath.row]
            if indexPath.row == 2
            {
                cell.Groups.textColor = .red
            }
        }
        
//        if indexPath.row == 2{
//            cell.Groups.textColor = .red
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Auth.auth().currentUser?.email == nil
        {
            return phoneItems.count
        }
        else
        {
            return emailItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        self.popDelegate?.selectedItem(index: indexPath.row)
//        selectedItem(index: indexPath.row)
        
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//extension popOverViewController:popoverDelegate{
//    func selectedItem(index: Int)
//    {
//        switch index {
//        case 0:
//            let cont = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupList") as! LIstOfGroupsViewController
//                   self.present(cont, animated: true) {
//                   }
//        case 1:
//            if delegate.currentUser == nil
//            {
//                self.handleLogout()
//            }
//            else
//            {
//                self.performSegue(withIdentifier: "changePw", sender: nil)
//            }
//        default:
//            self.handleLogout()
//        }
//
//    }
//    @objc func handleLogout()
//          {
//              do
//              {
//                  try Auth.auth().signOut()
//                  delegate.currentUser = nil
//                  self.logoutAlert(msg: "Do you want to logout ?", controller: self)
//                self.navigationController?.popToRootViewController(animated: true)
//              }
//              catch let logoutError
//              {
//                  print(logoutError)
//                  self.confirmationAlert(msg: logoutError.localizedDescription, controller: self)
//              }
//          }
//
//
//}

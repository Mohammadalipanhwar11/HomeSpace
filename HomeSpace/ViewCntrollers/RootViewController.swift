//
//  RootViewController.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/11/19.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

class RootViewController: UIViewController,UIGestureRecognizerDelegate {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var v:customView1!
    var pViewController:PageTabMenuViewController!
    var loadTaskSpecificPage = false
    var count = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            if let grpName = dict["openGroup"]{
                if grpName != ""{
                    if pViewController != nil{
                        self.managePageController()
                    }
                }
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        staticLinker.rootVc = self
        staticLinker.index = 0
        
        self.v = (Bundle.main.loadNibNamed("customView1", owner: nil, options: nil)![0] as! customView1)
        self.v.add.addTarget(self, action: #selector(add), for: .touchUpInside)
        self.v.search.addTarget(self, action: #selector(search), for: .touchUpInside)
        self.v.optionsButton.addTarget(self, action: #selector(option), for: .touchUpInside)
        v.frame = CGRect(x: 0, y: self.view.frame.size.height - 117, width: self.view.frame.size.width, height: 117)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        Firestore.firestore().collection("tasks").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { (snap, error) in
            snap?.documentChanges.forEach({ (task) in
                if self.loadTaskSpecificPage == true{
                
                    let object = task.document.data()
                    let taskData = try! FirestoreDecoder().decode(Task.self, from: object)
                    let id  = taskData.group!
                
                        switch task.type {
                        
                        case .added:
                            if let index = Task.sharedSearch.firstIndex(where: {$0.group.name == id}){
                                self.count = index
                            }
                            if let index = Task.sharedSearch.firstIndex(where: {$0.group.id == id}){
                                self.count = index
                            }
                            self.managePageController()
                        case.modified:
                            if let index = Task.sharedSearch.firstIndex(where: {$0.group.id == id}){
                                self.count = index + 1
                                let task = Task.sharedSearch[index].tasks
                                if let indx = task.firstIndex(where: {$0.date == taskData.date && $0.name == taskData.name && $0.group == taskData.group}){
                                    if task[indx].rank == taskData.rank && task[indx].name != taskData.name{
                                        self.managePageController()
                                    }
                                }
                                
                            }
                        case.removed:
                            print()
                    }
                }
                })
            }
        
        print(Auth.auth().currentUser!.uid)
        Firestore.firestore().collection("groups").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
                    .order(by: "date", descending: true)
                    .addSnapshotListener(includeMetadataChanges: true, listener: { (snap, err) in
                        snap?.documentChanges.forEach({ (group) in
                            
                            
                            let gID = group.document.documentID
                            let object = group.document.data()
                            var groupData = try! FirestoreDecoder().decode(Group.self, from: object)
                            groupData.id = gID
                            var index = 0
                            
                            switch group.type {
                            case .added:
                                
                                Task.sharedSearch.append((groupData,[]))
                                let groups = Task.sharedSearch.map({$0.group})
                                
                                print(groupData.id)
                                if let i = Task.sharedSearch.firstIndex(where: {$0.group.id == groupData.id}){
                                    index = i
                                }
                                self.count = index
                                
                            case .modified:
                                
                                let gIndex = Task.sharedSearch.firstIndex(where: {$0.group.id == groupData.id})
                                if let i = gIndex{
                                    let g = Task.sharedSearch[i]
                                    let data = (groupData,g.tasks)
                                    Task.sharedSearch[i] = data
                                    index = i
                                }
                                self.count = index
                                
                            case .removed:
                                
                                let gIndex = Task.sharedSearch.firstIndex(where: {$0.group.id == groupData.id})
                                    Task.sharedSearch.remove(at: gIndex!)
                                    if let indx = staticLinker.index{
                                        if indx == Task.sharedSearch.count - 1{
                                            index = indx
                                        }else if indx > Task.sharedSearch.count - 1{
                                            index = Task.sharedSearch.count - 1
                                        }else if gIndex == staticLinker.index && staticLinker.index - 1 > 0{
                                            index = staticLinker.index
                                        }else{
                                            index = 0
                                        }
                                    }
                                    self.count = index
                                    
                                }
                                self.managePageController()
                        })
                    })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.loadTaskSpecificPage = true
    }
    
    func changePage(groupID: String){
        if let index = Task.sharedSearch.firstIndex(where: {$0.group.id == groupID}){
            pViewController.count = index
            pViewController.reloadPages()
        }
    }
    
    func managePageController(){
        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            if let grpName = dict["openGroup"]{
                if grpName != ""{
                    if let cnt = Task.sharedSearch.firstIndex(where: {$0.group.name == grpName}){
                        self.count = cnt
                    }
                }
            }
        }
        let groups = Task.sharedSearch.map({$0.group})
        
        let pageViewController = PageTabMenuViewController(
            groups: groups,
            options: RoundRectPagerOption(isInfinite: true, tabMenuPosition: .top),count: count)
        if let _ = self.pViewController{
            self.navigationController?.popViewController(animated: false)
        }
        self.navigationController?.pushViewController(pageViewController, animated: false)
        self.pViewController = pageViewController
        if UIDevice.current.hasNotch{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 104))
            view.backgroundColor = .clear
            self.pViewController.view.addSubview(view)
        }else{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
            view.backgroundColor = .clear
            self.pViewController.view.addSubview(view)
        }
        self.pViewController.view.addSubview(v)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let dest = segue.destination as! editTaskViewController
            dest.text = staticLinker.selectedText
            dest.key1 = staticLinker.selectedKey
            dest.groupID = staticLinker.deleteTitle
            dest.deleteID = staticLinker.deleteID
            dest.deleteTitle = staticLinker.deleteTitle
            dest.reminder = staticLinker.reminder
        }
        if segue.identifier == "search"{
            let dest = segue.destination as! SearchAllGroupsViewController
            dest.data = Task.sharedSearch
        }
        
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
        if segue.source is editTaskViewController {
            if let senderVC = segue.source as? editTaskViewController {
                
            }
        }
        
    }
    
    @objc func option() {
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "pop") as? popOverViewController else { return }
        popVC.group = staticLinker.group
        popVC.popDelegate = self
        popVC.modalPresentationStyle = .popover
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = v.optionsButton
        popOverVC?.sourceRect = CGRect(x: v.optionsButton.bounds.midX, y: v.optionsButton.bounds.minY, width: 0, height: 0)
        if Auth.auth().currentUser?.email == nil || Auth.auth().currentUser?.email == ""
        {
            popVC.preferredContentSize = CGSize(width: 250, height: 140)
        }
        else
        {
            popVC.preferredContentSize = CGSize(width: 250, height: 210)
        }
        
        self.present(popVC, animated: true)
    }
    
    @objc func edit(){
        self.performSegue(withIdentifier: "edit", sender: nil)
    }
    
    @objc func search(){
        self.performSegue(withIdentifier: "search", sender: nil)
    }
    
    @objc func add(){
        self.performSegue(withIdentifier: "add", sender: nil)
    }

}
//extension RootViewController:popoverDelegate{
//
//    func selectedItem(index: Int) {
//        let cont = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupList") as! LIstOfGroupsViewController
//        self.present(cont, animated: true) {
//        }
//    }
//}

extension RootViewController:popoverDelegate{
    func selectedItem(index: Int) {
        switch index {
        case 0:
            let cont = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupList") as! LIstOfGroupsViewController
                   self.present(cont, animated: true) {
                   }
        case 1:
            if Auth.auth().currentUser?.email == nil
            {
                self.handleLogout()
            }
            else
            {
                self.performSegue(withIdentifier: "changePw", sender: nil)
            }
        default:
            self.handleLogout()
        }

    }


    @objc func handleLogout()
          {
              do
              {
                  try Auth.auth().signOut()
                  delegate.currentUser = nil
                  self.logoutAlert(msg: "Do you want to logout ?", controller: self)
              }
              catch let logoutError
              {
                  print(logoutError)
                  self.confirmationAlert(msg: logoutError.localizedDescription, controller: self)
              }
          }
}

extension RootViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

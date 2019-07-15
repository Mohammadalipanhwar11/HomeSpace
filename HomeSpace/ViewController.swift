//
//  ViewController.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import SwiftMoment
import SwiftReorder

class ViewController: UIViewController,TableViewReorderDelegate{
   
    
 
    var selectedText:String?
    var selectedKey:String?
    var timers = [Timer]()
    var arr = [Task](){
        didSet{
             self.mainTaskTable.reloadData()
        }
    }

    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var dateOfToday: UILabel!
    @IBOutlet weak var mainTaskTable: UITableView!
    private var myReorderImage : UIImage? = UIImage(named: "image")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTaskTable.estimatedRowHeight = 100 ;
        self.mainTaskTable.rowHeight = UITableView.automaticDimension;
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let result = formatter.string(from: date)
        dateOfToday.text = result
//        mainTaskTable.allowsSelection = false
//        mainTaskTable.delegate = self
//        mainTaskTable.dataSource = self
//        mainTaskTable.isEditing = true
       
        taskManager.shared.getAllTask { (taskArr, error) in
            if error == nil{
                self.arr = taskArr
                self.mainTaskTable.reloadData()
//                taskArr.forEach({ (t) in
//                    if self.arr.contains(where: {$0.0.id != t.id}){
//                        self.arr.append((t,false))
//                    }else{
//                        self.arr.append((t,true))
//                    }
//                })
            }else{
                //alert
            }
        }
        mainTaskTable.reorder.delegate = self
        mainTaskTable.reorder.cellScale = 1.07


    }
    
    

    @IBAction func option(_ sender: Any) {
        
    }
    @IBAction func addTask(_ sender: Any) {
        
    }
    @IBAction func search(_ sender: Any) {
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let dest = segue.destination as! editTaskViewController
            dest.text = selectedText
            dest.key1 = selectedKey
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{


    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedText = arr[indexPath.row].name
        self.selectedKey = arr[indexPath.row].id
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = mainTaskTable.dequeueReusableCell(withIdentifier: "cell") as! tasksTableViewCell
        cell.selectedBackgroundView?.backgroundColor = UIColor.black
        cell.taskLabel.text = arr[indexPath.row].name
        let diff = moment(self.arr[indexPath.row].date!.dateValue()) - moment()
        let posDiff = diff.minutes * -1
//        print(posDiff)


        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
//         Current Item which is choose to move
                var item = arr[initialSourceIndexPath.row]
                // Initially both are zero which we will use in index path is 0 so that first element is always zero
                var previousElementRank:Double = 0.0
                var updatedRank:Double = 0.0
        
                if finalDestinationIndexPath.row == (arr.count - 1){
                    // By default zero
                    //previousElementRank = 0
                    // Change already first element rank so that if comes on second
                    let destinationRank:Double = arr[finalDestinationIndexPath.row].rank!
                    let after = self.arr[finalDestinationIndexPath.row].rank!
                    // Dont make it zero again
                    updatedRank = (destinationRank + after) / 2.0
        //            arr[destinationIndexPath.row].rank! += 0.0001
        
                    taskManager.shared.updateTask(key: arr[finalDestinationIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                        if success{
                            print("Updated")
                            // Update task rank
                            taskManager.shared.updateTask(key: self.arr[initialSourceIndexPath.row].id!, updatedRank: 0) { (success) in
                                if success{
                                    print("Updated")
                                }else{
                                    print("Failed")
                                }
                            }
                        }else{
                            print("Failed")
                        }
                    }
                }else if finalDestinationIndexPath.row == 0{
                    // Manage last element
                    //
                    //previousElementRank = arr[(destinationIndexPath.row - 1)].rank!
                    // update moved task rank so that it is more than existing last element
                    updatedRank = ((arr[(finalDestinationIndexPath.row)].rank!) + 0.1)
                    // Update task rank
                    taskManager.shared.updateTask(key: arr[initialSourceIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                        if success{
                            print("Updated")
                        }else{
                            print("Failed")
                        }
                    }
        
                }else{
                    // Get previous element rank
                    if finalDestinationIndexPath.row < initialSourceIndexPath.row{
                        previousElementRank = arr[(finalDestinationIndexPath.row - 1)].rank!
                    }else{
                        previousElementRank = arr[(finalDestinationIndexPath.row + 1)].rank!
                    }
//                    previousElementRank = arr[(finalDestinationIndexPath.row + 1)].rank!
                    // moved task rank is average of destination
                    updatedRank = ((arr[(finalDestinationIndexPath.row)].rank!) + previousElementRank) / 2.0
                    // Update task rank
                    print(previousElementRank,arr[(finalDestinationIndexPath.row)].rank!)
                    print(updatedRank)
                    taskManager.shared.updateTask(key: arr[initialSourceIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                        if success{
                            print("Updated")
//                            taskManager.shared.updateTask(key: self.arr[finalDestinationIndexPath.row].id!, updatedRank: updatedRank) { (success) in
//                                if success{
//                                    print("Updated")
//                                }else{
//                                    print("Failed")
//                                }
//                            }
                        }else{
                            print("Failed")
                        }
                    }
                }
        
        
                // Update rank in current array
//                  arr[initialSourceIndexPath.row].rank = updatedRank
        //        if destinationIndexPath.row == 0 {
        //            item.rank = 0
        //        }
//                    arr.remove(at: initialSourceIndexPath.row)
//                    arr.insert(item, at: finalDestinationIndexPath.row)
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
//    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leftAction = UIContextualAction(style: .normal, title:  "delete", handler: { (ac:UIContextualAction, view:UIView, success:@escaping (Bool) -> Void) in
        
            let alert = UIAlertController(title: "Delete", message: "Do you really want to delete this note", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
                taskManager.shared.deleteTask(key: self.arr[indexPath.row].id!) { (err) in
                }
                success(true)
            }))
            self.present(alert, animated: true, completion: nil)
            
            
           
            
            
            
            
        })
        leftAction.backgroundColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [leftAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let rightAction = UIContextualAction(style: .normal, title:  "move", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("rightAction tapped")
            self.performSegue(withIdentifier: "Move", sender: self)
            success(true)
        })
        rightAction.backgroundColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [rightAction])
    }


}


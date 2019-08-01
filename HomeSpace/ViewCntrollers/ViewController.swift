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

class ViewController: UIViewController,TableViewReorderDelegate,UISearchBarDelegate{
   
    
 
    var selectedText:String?
    var selectedKey:String?
    var moveText:String?
    var deleteID:String?
    var deleteTitle:String?
    var reminder:String?
    var index:Int?
    var currentTask = [Task](){
        didSet{
            self.mainTaskTable.reloadData()
        }
    }
    var timers = [Timer]()
    var arr = [Task](){
        didSet{
             self.mainTaskTable.reloadData()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainTaskTable: UITableView!
    private var myReorderImage : UIImage? = UIImage(named: "image")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.backgroundColor = UIColor.black
        searchBar.delegate = self
        self.mainTaskTable.estimatedRowHeight = 100 ;
        self.mainTaskTable.rowHeight = UITableView.automaticDimension;
        
        mainTaskTable.reorder.delegate = self
        mainTaskTable.reorder.cellScale = 1.07
        taskManager.shared.getAllTask(group: self.title!) { (taskArr, error) in
            if error == nil{
                self.arr = taskArr
                print(taskArr)
                self.currentTask = taskArr
            }else{
                //alert
            }
        }

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {currentTask = arr; return}
        currentTask = arr.filter({ (task) -> Bool in
            (task.name?.contains(searchText))!
        })
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
            dest.groupID = self.title!
            dest.deleteID = self.deleteID
            dest.deleteTitle = self.deleteTitle
            dest.reminder = self.reminder
        }
        
        
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
        if segue.source is editTaskViewController {
            if let senderVC = segue.source as? editTaskViewController {
                
                
            }
        }
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{


    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTask.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedText = arr[indexPath.row].name
        self.selectedKey = arr[indexPath.row].id
        self.moveText = self.arr[indexPath.row].name
        self.deleteID = self.arr[indexPath.row].id
        self.deleteTitle = self.title!
        self.reminder = self.arr[indexPath.row].reminder
        
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        
        if  let cell1 = mainTaskTable.dequeueReusableCell(withIdentifier: "cell") as? tasksTableViewCell{
            cell1.selectedBackgroundView?.backgroundColor = UIColor.black
            cell1.taskLabel.text = currentTask[indexPath.row].name
            return cell1
            
        }else if let cell2 = mainTaskTable.dequeueReusableCell(withIdentifier: "cell1") as? tasksTableViewCell{
            let date = arr[indexPath.row].date?.dateValue()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let dateString = dateFormatter.string(from: date! as Date)
            
            
            if indexPath.row > 0 {
                let previousExpensesData = arr[indexPath.row - 1].date
                let day = Calendar.current.component(.day, from: date!) // Do not add above 'date' value here, you might get some garbage value. I know the code is redundant. You can adjust that.
                let previousDay = Calendar.current.component(.day, from: (arr[indexPath.row - 1].date?.dateValue())!)
                if day == previousDay {
                    cell2.dateLabel.text = ""
                } else {
                    cell2.dateLabel.text = dateString
                }
            }else{
                cell2.dateLabel.text = dateString
                print("Cannot return previous Message Index...\n\n")
            }
        }
        return UITableViewCell()
        
    }


    
//    func tableView(_ tableView: UITableView,
//                   heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        let expense = arr[indexPath.row].date?.dateValue()
//        
//        if indexPath.row > 0{
//            let day = Calendar.current.component(.day, from: expense!)
//            let previousDay = Calendar.current.component(.day, from: (arr[indexPath.row - 1].date?.dateValue())!)
//            if day == previousDay {
//                return 0.0
//            }else{
//                return 20.0
//            }
//        }
//        return 20.0
//    }
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
        
                    taskManager.shared.updateTask(key: arr[finalDestinationIndexPath.row].id!, group: self.title!, updatedRank: updatedRank) { (success) in
                        if success{
                            print("Updated")
                            // Update task rank
                            taskManager.shared.updateTask(key: self.arr[initialSourceIndexPath.row].id!, group: self.title!, updatedRank: 0) { (success) in
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
                    taskManager.shared.updateTask(key: arr[initialSourceIndexPath.row].id!, group: self.title!, updatedRank: updatedRank) { (success) in
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
                    taskManager.shared.updateTask(key: arr[initialSourceIndexPath.row].id!, group: self.title!, updatedRank: updatedRank) { (success) in
                        if success{
                            print("Updated")
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
    
    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let leftAction = UIContextualAction(style: .normal, title:  "delete", handler: { (ac:UIContextualAction, view:UIView, success:@escaping (Bool) -> Void) in
//
//            let alert = UIAlertController(title: "Delete", message: "Do you really want to delete this note", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil))
//            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
//                taskManager.shared.deleteTask(key: self.arr[indexPath.row].id!, group: self.title!, completion: { (err) in
//                    if err != nil {
//                        print(err)
//                    }
//                })
//                success(true)
//            }))
//            self.present(alert, animated: true, completion: nil)
//
//
//
//
//
//
//
//        })
//        leftAction.backgroundColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
//        return UISwipeActionsConfiguration(actions: [leftAction])
//    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let rightAction = UIContextualAction(style: .normal, title:  "move", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            print("rightAction tapped")
//            self.moveText = self.arr[indexPath.row].name
//            self.deleteID = self.arr[indexPath.row].id
//            self.deleteTitle = self.title!
//            self.performSegue(withIdentifier: "Move", sender: self)
//            success(true)
//        })
//        rightAction.backgroundColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
//        return UISwipeActionsConfiguration(actions: [rightAction])
//    }


}

extension Int64 {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}

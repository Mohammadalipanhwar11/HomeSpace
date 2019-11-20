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
import FirebaseAuth

class SwiftPageMenuTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

class ViewController: UIViewController,TableViewReorderDelegate{
   
    
 
    var selectedText:String?
    var selectedKey:String?
    var moveText:String?
    var deleteID:String?
    var deleteTitle:String?
    var reminder:String?
    var index:Int?
    
    var tapCount:Int = 0
    var tapTimer:Timer?
    var tappedRow:Int?
    
    var task = [Task]()
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
    
    var group:Group?{
        willSet{
            self.title = newValue?.name
        }
    }
    let delegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mainTaskTable: UITableView!
    private var myReorderImage : UIImage? = UIImage(named: "image")!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        staticLinker.group = self.group
        
        
        self.mainTaskTable.estimatedRowHeight = 100 ;
        self.mainTaskTable.rowHeight = UITableView.automaticDimension;
        
        mainTaskTable.reorder.delegate = self
        mainTaskTable.reorder.cellScale = 1.07
        self.automaticallyAdjustsScrollViewInsets = false
        taskManager.shared.getAllTask(group: self.group!.id!) { (taskArr, error) in
            if error == nil{
                self.task = taskArr
                self.arr = taskArr
                self.currentTask = taskArr
                if let gIndex = Task.sharedSearch.firstIndex(where: {$0.group.id == self.group!.id}){
                    Task.sharedSearch[gIndex].tasks = taskArr
                }
                self.mainTaskTable.reloadData()
            }else{
                //alert
            }
        }
//    }
//
//    @IBAction func option(_ sender: UIButton) {
//
//        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "pop") as? popOverViewController else { return }
//        popVC.group = self.group
//        popVC.popDelegate = self
//        popVC.modalPresentationStyle = .popover
//        let popOverVC = popVC.popoverPresentationController
//        popOverVC?.delegate = self
//        popOverVC?.sourceView = self.optionsButton
//        popOverVC?.sourceRect = CGRect(x: self.optionsButton.bounds.midX, y: self.optionsButton.bounds.minY, width: 0, height: 0)
//        if delegate.currentUser == nil
//        {
//            popVC.preferredContentSize = CGSize(width: 250, height: 140)
//        }
//        else
//        {
//            popVC.preferredContentSize = CGSize(width: 250, height: 200)
//        }
//        self.present(popVC, animated: true)
//    }
//
//
//    @IBAction func addTask(_ sender: Any) {
//
//    }
//
//
//    @IBAction func search(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "search", sender: nil)
//    }
//
//
//
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "edit" {
//            let dest = segue.destination as! editTaskViewController
//            dest.text = selectedText
//            dest.key1 = selectedKey
//            dest.groupID = self.title!
//            dest.deleteID = self.deleteID
//            dest.deleteTitle = self.deleteTitle
//            dest.reminder = self.reminder
//        }
//        if segue.identifier == "search"{
//            let dest = segue.destination as! SearchAllGroupsViewController
//            dest.data = Task.sharedSearch
//        }
//
//
//    }
//
//    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
//
//        if segue.source is editTaskViewController {
//            if let senderVC = segue.source as? editTaskViewController {
//
//            }
//        }
        
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
        
        if(tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row){
            
            staticLinker.selectedText = arr[indexPath.row].name
            staticLinker.selectedKey = arr[indexPath.row].id
            staticLinker.moveText = self.arr[indexPath.row].name
            staticLinker.deleteID = self.arr[indexPath.row].id
            staticLinker.deleteTitle = self.title!
            staticLinker.reminder = self.arr[indexPath.row].reminder

            staticLinker.rootVc.edit()
            
            tapTimer?.invalidate()
            tapTimer = nil
            tapCount = 0
        }
        else if(tapCount == 0){
            //This is the first tap. If there is no tap till tapTimer is fired, it is a single tap
            tapCount = tapCount + 1;
            tappedRow = indexPath.row;
            tapTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(tapTimerFired), userInfo: nil, repeats: false)
        }
        else if(tappedRow != indexPath.row){
            //tap on new row
            tapCount = 0;
            if(tapTimer != nil){
                tapTimer?.invalidate()
                //tapTimer = nil
            }
//        }
//        
//        NOTIFICATION FUNCTION
//
//        let notification = Notifications()
//
//        let okAction = UIAlertAction(title: "OK", style: .default)
//        {
//            (action) in
//
//
        }
        
    }
    
    
    @objc func tapTimerFired(){
    //timer fired, there was a single tap on indexPath.row = tappedRow
        if(tapTimer != nil){
            tapCount = 0;
            tappedRow = -1;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        
        if  let cell1 = mainTaskTable.dequeueReusableCell(withIdentifier: "cell") as? tasksTableViewCell{
            cell1.selectedBackgroundView?.backgroundColor = UIColor.black
            cell1.taskLabel.text = currentTask[indexPath.row].name
            if currentTask[indexPath.row].reminder == ""{
                cell1.reminder.isHidden = true
            }else{
                cell1.reminder.isHidden = false
            }
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
            if currentTask[indexPath.row].reminder == ""{
                cell2.reminder.isHidden = true
            }else{
                cell2.reminder.isHidden = false
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
                    let after = self.arr[initialSourceIndexPath.row].rank!
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
    }


}

//extension ViewController:popoverDelegate{
//    func selectedItem(index: Int) {
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
//    
//    
//    @objc func handleLogout()
//          {
//              do
//              {
//                  try Auth.auth().signOut()
//                  delegate.currentUser = nil
//                  self.logoutAlert(msg: "Do you want to logout ?", controller: self)
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

extension Int64 {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}
extension ViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}



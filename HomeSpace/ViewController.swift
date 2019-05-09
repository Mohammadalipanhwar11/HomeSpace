//
//  ViewController.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import SwiftMoment

class ViewController: UIViewController {
    
    var arr = [Task](){
        didSet{
             //self.mainTaskTable.reloadData()
        }
    }
    
        
    @IBOutlet weak var dateOfToday: UILabel!
    @IBOutlet weak var mainTaskTable: UITableView!
    private var myReorderImage : UIImage? = UIImage(named: "image")!
    var timers = [Timer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let result = formatter.string(from: date)
        dateOfToday.text = result
        mainTaskTable.allowsSelection = false
        mainTaskTable.delegate = self
        mainTaskTable.dataSource = self
        mainTaskTable.isEditing = true
       
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
        
    }
    
    

    @IBAction func option(_ sender: Any) {
        
    }
    @IBAction func addTask(_ sender: Any) {
        
    }
    @IBAction func search(_ sender: Any) {
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = mainTaskTable.dequeueReusableCell(withIdentifier: "cell") as! tasksTableViewCell
        cell.selectionStyle = .none
        cell.selectedBackgroundView?.backgroundColor = UIColor.black
        cell.taskLabel.text = arr[indexPath.row].name
        let diff = moment(self.arr[indexPath.row].date!.dateValue()) - moment()
        let posDiff = diff.minutes * -1
        print(posDiff)        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Current Item which is choose to move
        var item = arr[sourceIndexPath.row]
        // Initially both are zero which we will use in index path is 0 so that first element is always zero
        var previousElementRank:Double = 0.0
        var updatedRank:Double = 0.0
        
        if destinationIndexPath.row == 0{
            // By default zero
            //previousElementRank = 0
            // Change already first element rank so that if comes on second
            let destinationRank:Double = arr[destinationIndexPath.row].rank!
            let after = self.arr[destinationIndexPath.row+1].rank!
            // Dont make it zero again
            updatedRank = (destinationRank + after) / 2.0
//            arr[destinationIndexPath.row].rank! += 0.0001
            
            taskManager.shared.updateTask(key: arr[destinationIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                if success{
                    print("Updated")
                    // Update task rank
                    taskManager.shared.updateTask(key: self.arr[sourceIndexPath.row].id!, updatedRank: 0) { (success) in
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
        }else if destinationIndexPath.row == (arr.count - 1){
            // Manage last element
            //
            //previousElementRank = arr[(destinationIndexPath.row - 1)].rank!
            // update moved task rank so that it is more than existing last element
            updatedRank = ((arr[(destinationIndexPath.row)].rank!) + 0.1)
            // Update task rank
            taskManager.shared.updateTask(key: arr[sourceIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                if success{
                    print("Updated")
                }else{
                    print("Failed")
                }
            }
            
        }else{
            // Get previous element rank
            previousElementRank = arr[(destinationIndexPath.row - 1)].rank!
            // moved task rank is average of destination
            updatedRank = ((arr[(destinationIndexPath.row)].rank!) + previousElementRank) / 2.0
            // Update task rank
            taskManager.shared.updateTask(key: arr[sourceIndexPath.row].id!, updatedRank: updatedRank) { (success) in
                if success{
                    print("Updated")
                }else{
                    print("Failed")
                }
            }
        }
       
        
        // Update rank in current array
          arr[sourceIndexPath.row].rank = updatedRank
//        if destinationIndexPath.row == 0 {
//            item.rank = 0
//        }
            arr.remove(at: sourceIndexPath.row)
            arr.insert(item, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for subViewA in cell.subviews {
            subViewA.backgroundColor = UIColor.black
            if (subViewA.classForCoder.description() == "UITableViewCellReorderControl") {
                for subViewB in subViewA.subviews {
                    if (subViewB.isKind(of: UIImageView.classForCoder())) {
                        let imageView = subViewB as! UIImageView;
                        if (myReorderImage != nil) {
                            let myImage = imageView.image;
                            myReorderImage = myImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate);
                        }
                        imageView.image = myReorderImage;
                        imageView.tintColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
                        break;
                    }
                }
                break;
            }
        }
    }
    
    
}


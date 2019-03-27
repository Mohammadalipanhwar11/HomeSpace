//
//  ViewController.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import SwiftReorder



class ViewController: UIViewController {
    
    var arr = [Task](){
        didSet{
            self.mainTaskTable.reloadData()
        }
    }
    
        
    @IBOutlet weak var dateOfToday: UILabel!
    @IBOutlet weak var mainTaskTable: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTaskTable.allowsSelection = false
        mainTaskTable.reorder.delegate = self
        mainTaskTable.delegate = self
        mainTaskTable.dataSource = self
        
        
        
        taskManager.shared.getAllTask { (taskArr, error) in
            if error == nil{
                self.arr = taskArr
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

extension ViewController: UITableViewDelegate, UITableViewDataSource,TableViewReorderDelegate{

    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let cell = mainTaskTable.dequeueReusableCell(withIdentifier: "cell") as! tasksTableViewCell
        cell.taskLabel.text = arr[indexPath.row].name
        
        let lastRowIndex = mainTaskTable.numberOfRows(inSection: tableView.numberOfSections-1)
        if (indexPath.row == lastRowIndex - 1) {
            cell.View.layer.borderColor = UIColor.orange.cgColor

        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = arr[sourceIndexPath.row]
        arr.remove(at: sourceIndexPath.row)
        arr.insert(item, at: destinationIndexPath.row)
        
    }
    
    
}


//
//  taskManager.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class taskManager {
    
    static let shared = taskManager()
    typealias TasksCompletion = (_ tasks:[Task],_ error:String?)->Void
    typealias SucessCompletion = (_ error:String?)->Void

  
    
    func addTask(task:Task,completion:@escaping SucessCompletion){
        let maxOrderRef = Firestore.firestore().collection("maxOrder").document("rank")
        let taskRef = Firestore.firestore().collection("maxOrder").document("rank")

        Firestore.firestore().runTransaction({ (transactions, err) -> Any? in
            let rankDoc = try! transactions.getDocument(maxOrderRef)
            var newRank = 0.0
            var updatedtask = task
            if let rank = rankDoc.data()?["rank"] as? Double{
                newRank = rank + 10
                updatedtask.rank = newRank
                Firestore.firestore().collection("tasks").addDocument(data: updatedtask.toDic) { (err) in
                    if err != nil {
                        print(err?.localizedDescription as Any)
                    }
                    completion(nil)
                    transactions.updateData(["rank":newRank], forDocument: maxOrderRef)
                }
                return newRank
            }else{
                Firestore.firestore().collection("tasks").addDocument(data: updatedtask.toDic) { (err) in
                    if err != nil {
                        print(err?.localizedDescription as Any)
                    }
                    completion(nil)
                    transactions.setData(["rank":0], forDocument: maxOrderRef)
                }
                return newRank
            }

         
        }) { (data, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }

      
    }
    
    func getAllTask(completion:@escaping TasksCompletion){
        
        Firestore.firestore().collection("tasks")
            .addSnapshotListener { taskSnap, error in
                taskSnap?.documentChanges.forEach({ (task) in
                    let object = task.document.data()
                    let json = try! JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
                    var taskData = try! JSONDecoder().decode(Task.self, from: json)
                    taskData.id = task.document.documentID
                    
                    if (task.type == .added) {
                        Task.shared.append(taskData)
                    }
                    if (task.type == .modified) {
                        let index = Task.shared.firstIndex(where: { $0.id ==  taskData.id})!
                        Task.shared[index] = taskData
                    }
                })
                if error == nil{
                    completion(Task.shared,nil)
                }else{
                    completion([],error?.localizedDescription)
                }
        }

    }
    
}


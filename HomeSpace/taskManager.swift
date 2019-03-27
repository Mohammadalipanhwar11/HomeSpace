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
        Firestore.firestore().collection("tasks").addDocument(data: task.toDic) { (err) in
            if err != nil {
                print(err?.localizedDescription as Any)
            }
            completion(nil)

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


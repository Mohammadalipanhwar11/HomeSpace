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
import CodableFirebase

class taskManager {
    
    static let shared = taskManager()
    typealias TasksCompletion = (_ tasks:[Task],_ error:String?)->Void
    typealias SucessCompletion = (_ error:String?)->Void
    
    
    
    func addTask(task:Task,completion:@escaping SucessCompletion){
        Firestore.firestore().collection("tasks").document(task.group!).collection("Tasks").order(by: "rank", descending: true).limit(to: 1)
            .getDocuments { (data, err) in
                var rank = 0.0
                if let object = data?.documents.first?.data(){
                    let maxTask = try! FirestoreDecoder().decode(Task.self, from: object)
                    rank = maxTask.rank!
                    rank += 10
                } 
                var updated = task
                updated.rank = rank
                let data = try! FirestoreEncoder().encode(updated)
                Firestore.firestore().collection("tasks")
                    .document(task.group!)
                    .collection("Tasks")
                    .addDocument(data: data) { (err) in
                        completion(err?.localizedDescription)
                }
                
                Firestore.firestore().collection("tasks").document(task.group!).setData(["task" : "added"], completion: { (err) in
                    
                })
                
                
                
        }
    }
    
    func add(){
        Firestore.firestore().collection("tasks").document().setData(["rank" : 5])
    }
    
    
    
    
    func getAllTask(group: String,completion:@escaping TasksCompletion){
        Firestore.firestore().collection("tasks").document(group).collection("Tasks").order(by: "rank", descending: false)
            .addSnapshotListener { taskSnap, error in
                if Task.shared[group] == nil{
                    Task.shared[group] = []
                }
                taskSnap?.documentChanges.forEach({ (task) in
                    let object = task.document.data()
                    var taskData = try! FirestoreDecoder().decode(Task.self, from: object)
                    taskData.id = task.document.documentID
                    
                    if (task.type == .added) {
                        Task.shared[group]!.append(taskData)
                    }
                    if (task.type == .modified) {
                        let index = Task.shared[group]!.firstIndex(where: { $0.id ==  taskData.id})!
                        Task.shared[group]![index] = taskData
                    }
                    if (task.type == .removed) {
                        let index = Task.shared[group]!.firstIndex(where: { $0.id ==  taskData.id})!
                        Task.shared[group]!.remove(at: index)
                    }
                })
                if error == nil{
                    Task.shared[group]!.sort(by: {$0.rank! > $1.rank!})
                    completion(Task.shared[group]!,nil)
                }else{
                    completion([],error?.localizedDescription)
                }
        }
        
    }
    
    func updateTask(key:String, group: String,updatedRank:Double,completion:@escaping(_ success:Bool)->Void){
       Firestore.firestore().collection("tasks").document(group).collection("Tasks").document(key).updateData(["rank" : updatedRank]) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    func updateText(key:String,updatedRank:String, group: String,completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("tasks").document(group).collection("Tasks").document(key).updateData(["name" : updatedRank]) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    func deleteTask(key:String, group: String,completion:@escaping(_ success:Bool)->Void) {
         Firestore.firestore().collection("tasks").document(group).collection("Tasks").document(key).delete { (err) in
        }
    }
    

    
}


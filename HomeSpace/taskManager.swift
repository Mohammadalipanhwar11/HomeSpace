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
        Firestore.firestore().collection("tasks").order(by: "rank", descending: true).limit(to: 1)
            .getDocuments { (data, err) in
                var rank = 0.0
                if let object = data?.documents.first?.data(){
                    let maxTask = try! FirestoreDecoder().decode(Task.self, from: object)

//                    let json = try! JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
//                    let maxTask = try! JSONDecoder().decode(Task.self, from: json)
                    
                    rank = maxTask.rank!
                    rank += 10
                } 
                var updated = task
                updated.rank = rank
                let data = try! FirestoreEncoder().encode(updated)
                Firestore.firestore().collection("tasks").addDocument(data: data) { (err) in
                    completion(err?.localizedDescription)
                }
        }
    }
    
    func add(){
        Firestore.firestore().collection("tasks").document().setData(["rank" : 5])
    }
//
//    func show(){
//        let sfReference = Firestore.firestore().collection("cities").document("SF")
//
//        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
//            let sfDocument: DocumentSnapshot
//            do {
//                try sfDocument = transaction.getDocument(sfReference)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            guard let oldPopulation = sfDocument.data()?["population"] as? Int else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//
//            // Note: this could be done without a transaction
//            //       by updating the population using FieldValue.increment()
//            transaction.updateData(["population": oldPopulation + 1], forDocument: sfReference)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Transaction successfully committed!")
//            }
//        }
//            }
    
    func getAllTask(completion:@escaping TasksCompletion){
        
        Firestore.firestore().collection("tasks").order(by: "rank", descending: false)
            .addSnapshotListener { taskSnap, error in
                taskSnap?.documentChanges.forEach({ (task) in
                    let object = task.document.data()
                    var taskData = try! FirestoreDecoder().decode(Task.self, from: object)

//                    let json = try! JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
//                    var taskData = try! JSONDecoder().decode(Task.self, from: json)
                    taskData.id = task.document.documentID
                    
                    if (task.type == .added) {
                        Task.shared.append(taskData)
                        completion(Task.shared,nil)
                    }
                    if (task.type == .modified) {
                        let index = Task.shared.firstIndex(where: { $0.id ==  taskData.id})!
                        Task.shared[index] = taskData
                    }
                })
                if error == nil{
                    Task.shared.sort(by: {$0.rank! < $1.rank!})
                    completion(Task.shared,nil)
                }else{
                    completion([],error?.localizedDescription)
                }
        }

    }
    
    func updateTask(key:String,updatedRank:Double,completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("tasks").document(key).updateData(["rank" : updatedRank]) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    func deleteTask(key:String,completion:@escaping(_ success:Bool)->Void) {
        Firestore.firestore().collection("tasks").document(key).delete { (err) in
            if err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
}


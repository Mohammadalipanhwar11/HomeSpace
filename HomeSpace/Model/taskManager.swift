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
    typealias GroupCompletion = (_ tasks:[Group],_ error:String?)->Void
    typealias SucessCompletion = (_ error:String?)->Void
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    func deleteReminder(taskID:String){
        Firestore.firestore().collection("tasks").document(taskID).updateData(["reminder":""])
    }
    
    func addTask(task:Task,completion:@escaping SucessCompletion){
        Firestore.firestore()
            .collection("tasks").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).order(by: "rank", descending: true).limit(to: 1)
            .getDocuments { (data, err) in
                var rank = 0.0
                print(data?.documents.first)
                if let object = data?.documents.first?.data(){
                    let maxTask = try! FirestoreDecoder().decode(Task.self, from: object)
                    rank = maxTask.rank!
                    rank += 10
                } 
                var updated = task
                updated.rank = rank
                let data = try! FirestoreEncoder().encode(updated)
                Firestore.firestore().collection("tasks")
//                    .document(task.group!)
//                    .collection("Tasks")
                    .addDocument(data: data) { (err) in
                        completion(err?.localizedDescription)
                }
                
//                Firestore.firestore().collection("tasks").document(task.group!).setData(["task" : "added"], completion: { (err) in
//
//                })
                
                
                
        }
    }
    
    func add(){
        Firestore.firestore().collection("tasks").document().setData(["rank" : 5])
    }
    
    
    
    
    func getAllTask(group: String, completion:@escaping TasksCompletion){
        Firestore.firestore().collection("tasks").whereField("group", isEqualTo: group).whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).order(by: "rank", descending: false)
            .addSnapshotListener { taskSnap, error in
                if Task.shared[group] == nil{
                    Task.shared[group] = [:]
                }
                taskSnap?.documentChanges.forEach({ (task) in
                    let object = task.document.data()
                    print(object)
                    var taskData = try! FirestoreDecoder().decode(Task.self, from: object)
                    taskData.id = task.document.documentID
                    if (task.type == .added) {
                        Task.shared[group]![taskData.id!] = taskData
                    //  Task.shared[group]!.append(taskData)
                    }
                    if (task.type == .modified) {
                    //let index = Task.shared[group]!.firstIndex(where: { $0.id ==  taskData.id})!
                    //Task.shared[group]![index] = taskData
                    Task.shared[group]![taskData.id!] = taskData

                    }
                    if (task.type == .removed) {
                    //let index = Task.shared[group]!.firstIndex(where: { $0.id ==  taskData.id})!
                    //Task.shared[group]!.remove(at: index)
                    Task.shared[group]![taskData.id!] = nil
                    }
                })

                if error == nil{
//                    Task.shared[group]!.sort(by: {$0.rank! > $1.rank!})
                    let sorted = Task.shared[group]!.sorted(by: {$0.value.rank! > $1.value.rank!}).map({$0.value})
//                    completion(Task.shared[group]!,nil)
                    completion(sorted,nil)
                }else{
                    completion([],error?.localizedDescription)
                }
        }
        
    }
    
    func updateTask(key:String, group: String,updatedRank:Double,completion:@escaping(_ success:Bool)->Void){
       Firestore.firestore().collection("tasks").document(key).updateData(["rank" : updatedRank]) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    func updateText(key:String,updatedRank:String, group: String,completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("tasks").document(key).updateData(["name" : updatedRank]) { (error) in
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
    
    func updateReminder(key:String, group: String, reminder:String,  completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("tasks").document(key).updateData(["reminder":reminder]) { (err) in
            if err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    
    func getAllGroup(completion:@escaping GroupCompletion){
        Firestore.firestore().collection("groups").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
            .order(by: "date", descending: true)
            .addSnapshotListener({ (snap, err) in
                snap?.documentChanges.forEach({ (group) in
                    let gID = group.document.documentID
                    let object = group.document.data()
                    var groupData = try! FirestoreDecoder().decode(Group.self, from: object)
                    groupData.id = gID
                    switch group.type {
                    case .added, .modified:
                        Group.shared[gID] = groupData
                    case .removed:
                        Group.shared[gID] = nil
                    }
                })
                if err == nil{
                    completion(Group.shared.map({$0.value}).sorted(by: {$0.date!.dateValue() < $1.date!.dateValue()}),nil)
                }else{
                    completion([],err?.localizedDescription)
                }
            })

    }
    
    func createGroup(group:Group,  completion:@escaping(_ success:Bool)->Void){
     let data = try! FirestoreEncoder().encode(group)
        Firestore.firestore().collection("groups").addDocument(data: data) { (err) in
            if err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    
    func getGroupId(group: Group, completion:@escaping(_ id:String) -> Void){
        Firestore.firestore().collection("groups").whereField("name", isEqualTo: group.name!).whereField("date", isEqualTo: group.date!).getDocuments { (snapshot, error) in
            if let _ = error{
                completion("")
            }else{
                if let documents = snapshot?.documents{
                    if let id = (documents[0].documentID as? String){
                        completion(id)
                    }else{
                        completion("")
                    }
                }else{
                    completion("")
                }
            }
        }
    }
            
    func addTaskToNewGroup(mainText:String, taskText:String){
        let date = Date()
        let g = Group(name: mainText, date: date, uid: Auth.auth().currentUser!.uid)
        createGroup(group: g, completion: { (flag) in
            self.getGroupId(group: g) { (id) in
                if id != ""{
                    let t = Task(name: taskText, date: date, group: id, uid: Auth.auth().currentUser!.uid)
                    taskManager.shared.addTask(task: t) { (err) in
                    }
                }
            }
        })
    }
    
    func deleteGroup(group:Group,  completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("groups").document(group.id!).delete { (err) in
            if err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    
    func editGroup(group:Group, completion:@escaping(_ success:Bool)->Void){
        Firestore.firestore().collection("groups").document(group.id!).updateData(["name":group.name!,"date":Date()]) { (err) in
            if err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }

    
}


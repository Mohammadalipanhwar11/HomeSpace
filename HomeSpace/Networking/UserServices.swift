//
//  UserServices.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/4/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class userFunctions
{
    //MARK: -Constants
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let db = Firestore.firestore()
    
    //MARK: -Create User
    func createUser(user:User?,completion:@escaping(String?,User?, Bool?,String?)->Void)
    {
        
        var ref:DocumentReference? = nil
        
        Auth.auth().createUser(withEmail: user!.email!, password: user!.password!)
        { (result, mainErr) in
            
            if mainErr == nil
            {
                
                var users:User? = User(uid: user!.uid, firstName: user!.firstName, lastName: user!.lastName, email: user!.email, password: user!.password, phoneNo: user!.phoneNo)
                
                users?.uid = result!.user.uid
                users?.firstName = user!.lastName
                users?.lastName = user!.lastName
                users?.password = user!.password
                users?.email = user!.email
                users?.phoneNo = user!.phoneNo
                print("created")

                
                let dataDic:[String:Any] = ["firstName"     : "\(users!.firstName!)",
                                            "lastName"      : "\(users!.lastName!)",
                                            "email"         : "\(users!.email!)",
                                            "uid"           : "\(users!.uid!)",
                                            "phoneNo"       : "\(users!.phoneNo!)"
                                            ]
                
                ref = self.db.collection("Users").document("\(users!.uid!)")
                ref?.setData(dataDic)
                {
                    err in
                    if let err = err
                    {
                        print("Error : \(err.localizedDescription)")
                        completion(nil,nil,false,err.localizedDescription)
                    }
                    else
                    {
                        print("Created")
                        completion(nil,users,true,nil)
                    }
                }
            }
            else
            {
                let authError = mainErr?.localizedDescription
                completion(authError ,nil, false , nil)
            }
        }
    }
    
    
    //MARK: -Login
    func login(email:String,password:String,completion:@escaping(User?,String?,Bool?)->Void)
    {
        
        delegate.currentUser = User(uid: "asd", firstName: "asd", lastName:
            "asd", email: "asd", password: "asd", phoneNo: 000)
        
        Auth.auth().signIn(withEmail: email, password: password)
        {
            (result, error) in

            guard let user = result?.user else
            {
                print("Error : \(error!.localizedDescription)")
                completion(nil,error!.localizedDescription,false)
                return
            }
            
            let uid = user.uid
            print(uid)
            
            let ref = self.db.collection("Users").document("\(uid)")
            
            ref.getDocument(
                completion: {
                    (snapshot, error) in
                    
                    guard let snapshot = snapshot else
                    {
                        print("Error: \(error!.localizedDescription)")
                        completion(nil,error!.localizedDescription,false)
                        return
                    }
                    
                    self.delegate.currentUser!.firstName = snapshot.data()!["name"] as? String
                    self.delegate.currentUser!.lastName = snapshot.data()!["name"] as? String
                    self.delegate.currentUser!.email = snapshot.data()!["email"] as? String
                    self.delegate.currentUser!.uid = snapshot.data()!["uid"] as? String
                    self.delegate.currentUser!.phoneNo = snapshot.data()!["uid"] as? Int
                    
                    completion(self.delegate.currentUser,nil,true)
            })
        }
    }
    
    
    //MARK: -Upload Image
//    func uploadImg(uid:String?,image:UIImage?,completion:@escaping(_ url:String?,_ error:String?)->Void)
//    {
//        let storageRef:StorageReference!
//        storageRef = Storage.storage().reference()
//
//        let storageFile = storageRef.child("ProfileImage").child("\(uid)")
//
//        var imageData:Data? = nil
//
//
//        imageData = image?.jpegData(compressionQuality: 0.2)
//        print(imageData!)
//
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpg"
//
//        storageFile.putData(imageData!, metadata: metaData)
//        {
//            (metaData, error) in
//
//            guard let metaData = metaData
//            else
//            {
//                print("ERROR : \(error?.localizedDescription)")
//                return
//            }
//
//            storageFile.downloadURL(completion:
//                {
//                    (url, error) in
//                    guard let downloadURL = url?.absoluteString else
//                    {
//                        print(error?.localizedDescription ?? "Error")
//                        completion(nil,error?.localizedDescription)
//                        return
//                    }
//                    print(downloadURL)
//
//                    completion(downloadURL,nil)
//                })
//        }
//    }
    
    //MARK: -Update Image URL
//    func updateIMGUrl(users:User?,url:String?)
//    {
//        let ref = self.db.collection("Users").document("\(users!.uid!)")
//        ref.setData(["picURL" : "\(url!)"], merge: true)
//    }
    
    //MARK: -Phone Number Verification
    
    func phoneAuth(PhoneNo:String?)
    {
        PhoneAuthProvider.provider().verifyPhoneNumber(PhoneNo!, uiDelegate: nil)
        {
            (verification, err) in
            
            if let err = err
            {
                print(err.localizedDescription)
                return
            }
            
            UserDefaults.standard.set(verification, forKey: "authVerificationID")
            
        }
    }
    
    
}

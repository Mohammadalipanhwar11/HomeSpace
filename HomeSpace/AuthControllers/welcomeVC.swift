//
//  welcomeVC.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/6/19.
//  Copyright © 2019 Fahad Saleem. All rights reserved.
//

import UIKit
import FirebaseAuth

class welcomeVC: UIViewController
{

    //MARK: -Constants
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let support = supportFunctions()
    
    
    //MARK: -Variables
    
    //MARK: -Outlets
    @IBOutlet weak var pwChange: UIButton!
    
    //MARK: -Actions
    
    @IBAction func logout(_ sender: UIButton)
    {
        handleLogout()
    }
    
    //MARK: -Functions
    @objc func handleLogout()
    {
        do
        {
            try Auth.auth().signOut()
            
            delegate.currentUser = nil
            self.logoutAlert(msg: "Do you want to logout ?", controller: self)
        }
        catch let logoutError
        {
            print(logoutError)
            self.confirmationAlert(msg: logoutError.localizedDescription, controller: self)
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        support.setCornerRadius(button: pwChange)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print(delegate.currentUser)
    }

}

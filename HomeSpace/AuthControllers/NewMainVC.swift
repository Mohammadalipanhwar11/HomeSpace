import UIKit

class NewMainVC: UIViewController
{
    //MARK: -Constants
    
    
    //MARK: -Variables
    
    
    //MARK: -Outlets
    
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    
    //MARK: -Actions
    @IBAction func emailSingIn(_ sender: UIButton)
    {
        
    }
    
    @IBAction func phoneSignIn(_ sender: UIButton)
    {
        
    }
    
    
    //MARK: -Functions
    
    func getCornerRadius(button:UIButton)
    {
        let height = button.frame.height
        button.layer.cornerRadius = height/2
    }
    
    override func viewDidLayoutSubviews()
    {
        getCornerRadius(button: emailBtn)
        getCornerRadius(button: phoneBtn)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
}

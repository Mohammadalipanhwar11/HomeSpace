import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import JVFloatLabeledTextField
import MBProgressHUD

class ChangePasswordVC: UIViewController
{
    //MARK: -Constants
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let support = supportFunctions()
    

    //MARK: -Variables
    var user = Auth.auth().currentUser
    
    
    //MARK: -Outlets
    @IBOutlet weak var newPw: JVFloatLabeledTextField!
    @IBOutlet weak var retypePw: JVFloatLabeledTextField!
    @IBOutlet weak var chagePwBtn: UIButton!
    
    //MARK: -Actions
    
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePw(_ sender: UIButton)
    {
        if newPw.text?.isEmpty == true
        {
            alert(msg: "Enter New Password", controller: self, textField: newPw)
        }
        else if retypePw.text?.isEmpty == true
        {
            alert(msg: "Retype New Password", controller: self, textField: retypePw)
        }
        else if newPw.text! != retypePw.text!
        {
            confirmationAlert(msg: "Passwords do not match", controller: self)
        }
        else
        {
            changePassword()
        }
    }
    

    //MARK: -Functions
    
    func changePassword()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        user?.updatePassword(to: newPw.text!, completion:
            {
                (err) in
                
                if let err = err
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.confirmationAlert(msg: err.localizedDescription, controller: self)
                }
                else
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.successAlert(msg: "Password Changed Successfully", controller: self)
                }
        })
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews()
    {
        support.getBottomLine(textField: newPw)
        support.getBottomLine(textField: retypePw)
        support.setCornerRadius(button: chagePwBtn)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

}

import UIKit
import FirebaseAuth
import JVFloatLabeledTextField
import MBProgressHUD

class ForgotPasswordVC: UIViewController
{
    //MARK: -Constants
    let support = supportFunctions()

    //MARK: -Variables

    //MARK: -Outlets
    @IBOutlet weak var email: JVFloatLabeledTextField!
    
    @IBOutlet weak var resetPw: UIButton!
    
    //MARK: -Actions
    
    @IBAction func backBtn(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPwRequest(_ sender: UIButton)
    {
        if email.text?.isEmpty == true
        {
            alert(msg: "Email Missing", controller: self, textField: email)
        }
        else
        {
            sendPwResetRequest()
        }
    }
    
    //MARK: -Functions
    
    func sendPwResetRequest()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        var auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: "\(email.text!)")
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
                self.successAlert(msg: "Password Resent Email Sent. Check you email.", controller: self)
//                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews()
    {
        support.getBottomLine(textField: email)
        support.setCornerRadius(button: resetPw)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

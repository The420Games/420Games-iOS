//
//  FTSignupWithEmailViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 02..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTSignupWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypeTextField: UITextField!
    
    private let minimumPasswordLength = 6
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Sign up", comment: "Sign up with email navigation title")
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        if validData() {
            signup()
        }
    }
    
    private func signup() {
        
        let user = User()
        
        user.email = emailTextField.text!
        user.password = passwordTextField.text!
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing up with Email", comment: "HUD title when signing up with Email")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.signup(user) { (success, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
                if success && error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    var message: String!
                    
                    switch error!.code {
                    case 3033: message = NSLocalizedString("Email already taken:(", comment: "Error message when email already taken")
                    default: message = NSLocalizedString("Failed to sign up:(", comment: "General error message when signup failed")
                    }
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if emailTextField.text == nil || emailTextField.text!.isEmpty {
            
            errors.append(NSLocalizedString("Please set your email address!", comment: "Error message when email missing"))
        }
        else if !emailTextField.text!.validEmailFormat() {
            
            errors.append(NSLocalizedString("Please provide valif email!", comment: "Error message when email invalid"))
        }
        
        if passwordTextField.text == nil || passwordTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < minimumPasswordLength {
            
            errors.append(NSLocalizedString("Password too short!", comment: "Error message when password too short"))
        }
        else if retypeTextField.text != nil && retypeTextField.text! != passwordTextField.text! {
            
            errors.append(NSLocalizedString("Passwords don't match!", comment: "Error messahe when passwords don't match"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
}

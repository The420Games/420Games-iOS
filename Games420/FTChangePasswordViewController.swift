//
//  FTChangePasswordViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 09..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTChangePasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: FTTextField!
    @IBOutlet weak var retypeTextField: FTTextField!
    @IBOutlet weak var changeButton: UIButton!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customizations
    
    private func setupUI() {
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonTouched(_:)))
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Change password", comment: "Change password navigation title")
        
        changeButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("CHANGE PASSWORD", comment: "Chanage password button title"))
        
        passwordTextField.ft_setup()
        passwordTextField.ft_setPlaceholder(NSLocalizedString("NEW PASSWORD", comment: "New password placeholder"))
        
        retypeTextField.ft_setup()
        retypeTextField.ft_setPlaceholder(NSLocalizedString("RETYPE PASSWORD", comment: "Retype password placeholder"))
    }
    
    // MARK: - Actions
    
    @IBAction func changeButtonTouched(sender: AnyObject) {
        
        endEditing()
        
        if validData() {
            changePassword(passwordTextField.text!)
        }
    }
    
    @IBAction func textfieldDidExit(sender: FTTextField) {
        
        sender.resignFirstResponder()
    }
    
    func backButtonTouched(sender: AnyObject) {
        
        dismiss()
    }
    
    private func dismiss() {
        
        endEditing()
        
        if let navController = navigationController {
            navController.popViewControllerAnimated(true)
        }
        else if presentingViewController != nil {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func endEditing() {
        
        passwordTextField.resignFirstResponder()
        retypeTextField.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if passwordTextField.text == nil || passwordTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < User.minimumPasswordLength {
            
            errors.append(NSLocalizedString("Password too short!", comment: "Error message when password too short"))
        }
        else if retypeTextField.text != nil && retypeTextField.text! != passwordTextField.text! {
            
            errors.append(NSLocalizedString("Passwords don't match!", comment: "Error messahe when passwords don't match"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    private func changePassword(newPassword: String) {
        
        FTDataManager.sharedInstance.currentUser!.password = newPassword
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Changing password", comment: "HUD title when changing password")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.currentUser?.saveInBackgroundWithBlock({ (success, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
                if success && error == nil {
                    
                    self.dismiss()
                }
                else {
                    var message: String!
                    
                    switch error!.code {
                    case 3072: message = NSLocalizedString("Can't change password if signed up with social account", comment: "Error message when social user cannot change password")
                    default: message = NSLocalizedString("Failed to change password up:(", comment: "General error message when password change failed")
                    }
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        })
    }

}

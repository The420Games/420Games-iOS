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
    
    fileprivate func setupUI() {
        
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
    
    @IBAction func changeButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        
        if validData() {
            changePassword(passwordTextField.text!)
        }
    }
    
    @IBAction func textfieldDidExit(_ sender: FTTextField) {
        
        sender.resignFirstResponder()
    }
    
    func backButtonTouched(_ sender: AnyObject) {
        
        dismiss()
    }
    
    fileprivate func dismiss() {
        
        endEditing()
        
        if let navController = navigationController {
            navController.popViewController(animated: true)
        }
        else if presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func endEditing() {
        
        passwordTextField.resignFirstResponder()
        retypeTextField.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
    fileprivate func validData() -> Bool {
        
        var errors = [String]()
        
        if passwordTextField.text == nil || passwordTextField.text!.lengthOfBytes(using: String.Encoding.utf8) < User.minimumPasswordLength {
            
            errors.append(NSLocalizedString("Password too short!", comment: "Error message when password too short"))
        }
        else if retypeTextField.text != nil && retypeTextField.text! != passwordTextField.text! {
            
            errors.append(NSLocalizedString("Passwords don't match!", comment: "Error messahe when passwords don't match"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joined(separator: "\n"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    fileprivate func changePassword(_ newPassword: String) {
        
        FTDataManager.sharedInstance.currentUser!.password = newPassword
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Changing password", comment: "HUD title when changing password")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.currentUser?.saveInBackgroundWithBlock({ (success, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if success && error == nil {
                    
                    self.dismiss()
                }
                else {
                    var message: String!
                    
                    switch error!.code {
                    case 3072: message = NSLocalizedString("Can't change password if signed up with social account", comment: "Error message when social user cannot change password")
                    default: message = NSLocalizedString("Failed to change password up:(", comment: "General error message when password change failed")
                    }
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        })
    }

}

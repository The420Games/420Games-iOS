//
//  FTSigninWithEmailViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 04..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTSigninWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: FTTextField!
    
    @IBOutlet weak var passwordTextField: FTTextField!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var signinButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var userName: String?
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.text = userName
    }
    
    // MARK: - UI Customizations
    
    fileprivate func setupUI() {
        
        title = NSLocalizedString("Log in", comment: "Sign in with email navigation title")
        view.backgroundColor =  UIColor.ftMainBackgroundColor()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        signinButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("LOG IN", comment: "Sign in button title"))
        
        signupButton.ft_setupButton(UIColor.ftGrassGreen(), title: NSLocalizedString("NO ACCOUNT YET? SIGN UP!", comment: "Email signup button title"))
        
        emailTextField.ft_setup()
        emailTextField.ft_setPlaceholder(NSLocalizedString("EMAIL", comment: "Email placeholder"))
        
        passwordTextField.ft_setup()
        passwordTextField.ft_setPlaceholder(NSLocalizedString("PASSWORD", comment: "Password placeholder"))
        
        resetButton.backgroundColor = UIColor.clear
        let resetTitle =  NSAttributedString(string: NSLocalizedString("Forgot your password?", comment: "Forgot password button title"), attributes: [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(.light, size: 12.7)!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
            ])
        resetButton.setAttributedTitle(resetTitle, for: UIControlState())
    }
    
    // MARK: - Actions
    
    func backButtonPressed(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {

        self.isEditing = false
        
        if validResetData() {

            resetPassword()
        }
    }
    
    @IBAction func signinButtonPressed(_ sender: AnyObject) {
        
        self.isEditing = false
        
        if validSignInData() {
            
            signIn()
        }
    }
    
    @IBAction func textfieldExit(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
    fileprivate func displayErrors(_ errors: [String]!) {
        
        let alert = UIAlertController(title: nil, message: errors.joined(separator: "\n"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func validateEmail(_ errors: inout [String]) {
        
        if emailTextField.text == nil || emailTextField.text!.isEmpty {
            
            errors.append(NSLocalizedString("Please set your email address!", comment: "Error message when email missing"))
        }
        else if !emailTextField.text!.validEmailFormat() {
            
            errors.append(NSLocalizedString("Please provide valid email!", comment: "Error message when email invalid"))
        }
    }
    
    fileprivate func validSignInData() -> Bool {
        
        var errors = [String]()
        
        validateEmail(&errors)
        
        if passwordTextField.text == nil || passwordTextField.text!.isEmpty {
            
            errors.append(NSLocalizedString("Password too short!", comment: "Error message when password too short"))
        }
        
        if errors.count > 0 {
            
            displayErrors(errors)
            
            return false
        }
        
        return true
    }
    
    fileprivate func validResetData() -> Bool {
        
        var errors = [String]()
        
        validateEmail(&errors)
        
        if errors.count > 0 {
            
            displayErrors(errors)
            
            return false
        }
        
        return true
    }
    
    fileprivate func signIn() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing in", comment: "HUD title when signing in with Email")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.login(emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if user != nil {
                    
                    FTAnalytics.trackEvent(.SignIn, data: ["mode": "Email" as AnyObject])

                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    var message: String!
                    
                    switch error!.code {
                    
                    case 3000: message = NSLocalizedString("Your account is disabled", comment: "Disabled account error message")
                    case 3003,
                        3006: message = NSLocalizedString("Invalid Login Credentials", comment: "Login error message when username or password missed")
                    case 3036: message = NSLocalizedString("Account locked out due too many failed attempts", comment: "Error message when acocunt locked due too many failed attempts")
                    case 3087: message = NSLocalizedString("Looks like you need to confirm your email first. Please visit your email to confirm your account. Thanks.", comment: "Error message when email needs to be confirmed");
                    break;
                    default: message = String(format: NSLocalizedString("Login failed to technical error. Code %li", comment: "General login error message"), error!.code);
                    }
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    fileprivate func resetPassword() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Resetting password", comment: "HUD title when resetting password")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.resetPassword(emailTextField.text!) { (success, error) in

            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if success {
                    
                    FTAnalytics.trackEvent(.PasswordReset, data: nil)
                    
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.label.text = NSLocalizedString("Success", comment: "HUD title when password reset succeeded")
                    hud.detailsLabel.text = NSLocalizedString("Check your email for instructions", comment: "HUD subtitle when password reset succeeded")
                    hud.mode = .text
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
                        
                        hud.hide(animated: true)
                    }
                }
                else {
                    
                    let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to reset password:(", comment: "Error message when failed to reset password"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}

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
    
    private func setupUI() {
        
        title = NSLocalizedString("Log in", comment: "Sign in with email navigation title")
        view.backgroundColor =  UIColor.ftMainBackgroundColor()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        signinButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("LOG IN", comment: "Sign in button title"))
        
        signupButton.ft_setupButton(UIColor.ftGrassGreen(), title: NSLocalizedString("NO ACCOUNT YET? SIGN UP!", comment: "Email signup button title"))
        
        emailTextField.ft_setup()
        emailTextField.ft_setPlaceholder(NSLocalizedString("EMAIL", comment: "Email placeholder"))
        
        passwordTextField.ft_setup()
        passwordTextField.ft_setPlaceholder(NSLocalizedString("PASSWORD", comment: "Password placeholder"))
        
        resetButton.backgroundColor = UIColor.clearColor()
        let resetTitle =  NSAttributedString(string: NSLocalizedString("Forgot your password?", comment: "Forgot password button title"), attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 12.7)!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ])
        resetButton.setAttributedTitle(resetTitle, forState: .Normal)
    }
    
    // MARK: - Actions
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {

        self.editing = false
        
        if validResetData() {

            resetPassword()
        }
    }
    
    @IBAction func signinButtonPressed(sender: AnyObject) {
        
        self.editing = false
        
        if validSignInData() {
            
            signIn()
        }
    }
    
    @IBAction func textfieldExit(sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
    private func displayErrors(errors: [String]!) {
        
        let alert = UIAlertController(title: nil, message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func validateEmail(inout errors: [String]) {
        
        if emailTextField.text == nil || emailTextField.text!.isEmpty {
            
            errors.append(NSLocalizedString("Please set your email address!", comment: "Error message when email missing"))
        }
        else if !emailTextField.text!.validEmailFormat() {
            
            errors.append(NSLocalizedString("Please provide valid email!", comment: "Error message when email invalid"))
        }
    }
    
    private func validSignInData() -> Bool {
        
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
    
    private func validResetData() -> Bool {
        
        var errors = [String]()
        
        validateEmail(&errors)
        
        if errors.count > 0 {
            
            displayErrors(errors)
            
            return false
        }
        
        return true
    }
    
    private func signIn() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing in", comment: "HUD title when signing in with Email")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.login(emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
                if user != nil {
                    
                    FTAnalytics.trackEvent(.SignIn, data: ["mode": "Email"])

                    self.navigationController?.popToRootViewControllerAnimated(true)
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
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    private func resetPassword() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Resetting password", comment: "HUD title when resetting password")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.resetPassword(emailTextField.text!) { (success, error) in

            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
                if success {
                    
                    FTAnalytics.trackEvent(.PasswordReset, data: nil)
                    
                    let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud.label.text = NSLocalizedString("Success", comment: "HUD title when password reset succeeded")
                    hud.detailsLabel.text = NSLocalizedString("Check your email for instructions", comment: "HUD subtitle when password reset succeeded")
                    hud.mode = .Text
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        
                        hud.hideAnimated(true)
                    }
                }
                else {
                    
                    let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to reset password:(", comment: "Error message when failed to reset password"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}

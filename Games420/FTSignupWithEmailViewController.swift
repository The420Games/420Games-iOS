//
//  FTSignupWithEmailViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 02..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTSignupWithEmailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: FTTextField!
    @IBOutlet weak var passwordTextField: FTTextField!
    @IBOutlet weak var retypeTextField: FTTextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var passwordHintLabel: UILabel!
    
    @IBOutlet weak var termsCheckButton: UIButton!
    
    @IBOutlet weak var termsHintLabel: UILabel!
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Customizations
    
    private func setupUI() {
        
        title = NSLocalizedString("Sign up", comment: "Sign up with email navigation title")
        view.backgroundColor =  UIColor.ftMainBackgroundColor()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        signupButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("SIGN UP", comment: "Sign up button title"))
        
        emailTextField.ft_setup()
        emailTextField.ft_setPlaceholder(NSLocalizedString("EMAIL", comment: "Email placeholder"))        
        
        passwordTextField.ft_setup()
        passwordTextField.ft_setPlaceholder(NSLocalizedString("PASSWORD", comment: "Password placeholder"))
        
        retypeTextField.ft_setup()
        retypeTextField.ft_setPlaceholder(NSLocalizedString("RETYPE PASSWORD", comment: "Retype password placeholder"))
        
        passwordHintLabel.font = UIFont.defaultFont(.Light, size: 12.7)
        passwordHintLabel.textColor = UIColor.whiteColor()
        passwordHintLabel.text = NSLocalizedString("Password must be at least six characters long.", comment: "Password hint label")
        
        termsCheckButton.ft_setupCheckBox()
        termsCheckButton.ft_setChecked(false)
        
        let hintAttrStr = NSMutableAttributedString(string: NSLocalizedString("I have read and accepted the ", comment: "Terms hint label part 1"), attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 12.7)!
            ])
        
        hintAttrStr.appendAttributedString(NSAttributedString(string: NSLocalizedString("Terms And Conditions", comment: "Terms hint label part 2 (underlined)"), attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 12.7)!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]))
        termsHintLabel.attributedText = hintAttrStr
    }
    
    // MARK: - Actions
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        self.editing = false
        
        if validData() {
            signup()
        }
    }
    
    @IBAction func termsCheckButtonPressed(sender: AnyObject) {
        
        termsCheckButton.ft_setChecked(!termsCheckButton.ft_Checked())
    }
    
    @IBAction func termsHintLabelTouched(sender: AnyObject) {
    }
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func textfieldDidExit(sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
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
                    
                    let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud.label.text = NSLocalizedString("Success", comment: "HUD title when signing up with Email succeeded")
                    hud.detailsLabel.text = NSLocalizedString("Check your email for instructions", comment: "HUD subtitle when email signup succeeded")
                    hud.mode = .Text
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        
                        hud.hideAnimated(true)
                        
                        self.performSegueWithIdentifier("signIn", sender: self)
                    }
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
            
            errors.append(NSLocalizedString("Please provide valid email!", comment: "Error message when email invalid"))
        }
        
        if passwordTextField.text == nil || passwordTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < User.minimumPasswordLength {
            
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

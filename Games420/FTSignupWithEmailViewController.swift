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
    
    fileprivate let signinSegueId = "signin"
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Customizations
    
    fileprivate func setupUI() {
        
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
        
        passwordHintLabel.font = UIFont.defaultFont(.light, size: 12.7)
        passwordHintLabel.textColor = UIColor.white
        passwordHintLabel.text = NSLocalizedString("Password must be at least six characters long.", comment: "Password hint label")
        
        termsCheckButton.ft_setupCheckBox()
        termsCheckButton.ft_setChecked(false)
        
        let hintAttrStr = NSMutableAttributedString(string: NSLocalizedString("I have read and accepted the ", comment: "Terms hint label part 1"), attributes: [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(.light, size: 12.7)!
            ])
        
        hintAttrStr.append(NSAttributedString(string: NSLocalizedString("Terms And Conditions", comment: "Terms hint label part 2 (underlined)"), attributes: [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(.light, size: 12.7)!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
            ]))
        termsHintLabel.attributedText = hintAttrStr
    }
    
    // MARK: - Actions
    
    @IBAction func signupButtonPressed(_ sender: AnyObject) {
        
        self.isEditing = false
        
        if validData() {
            signup()
        }
    }
    
    @IBAction func termsCheckButtonPressed(_ sender: AnyObject) {
        
        termsCheckButton.ft_setChecked(!termsCheckButton.ft_Checked())
    }
    
    @IBAction func termsHintLabelTouched(_ sender: AnyObject) {
        
        if let url = URL(string: FTTermsAndConditionsLink) {
            
            if UIApplication.shared.canOpenURL(url) {
                
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func backButtonPressed(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textfieldDidExit(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: - Data integration
    
    fileprivate func signup() {
        
        let user = User()
        
        let userName = emailTextField.text!
        user.email = userName
        user.password = passwordTextField.text!
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing up with Email", comment: "HUD title when signing up with Email")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.signup(user) { (success, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if success && error == nil {
                    
                    FTAnalytics.trackEvent(.SignUp, data: ["mode": "Email" as AnyObject])
                    
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.label.text = NSLocalizedString("Success", comment: "HUD title when signing up with Email succeeded")
                    hud.detailsLabel.text = NSLocalizedString("Check your email for instructions", comment: "HUD subtitle when email signup succeeded")
                    hud.mode = .text
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
                        
                        hud.hide(animated: true)
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    var message: String!
                    
                    switch error!.code {
                    case 3033: message = NSLocalizedString("Email already taken:(", comment: "Error message when email already taken")
                    default: message = NSLocalizedString("Failed to sign up:(", comment: "General error message when signup failed")
                    }
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    fileprivate func validData() -> Bool {
        
        var errors = [String]()
        
        if !termsCheckButton.ft_Checked() {
            errors.append(NSLocalizedString("Please accept Terms And Conditions!", comment: "Error message when terms not accepted"))
        }
        
        if emailTextField.text == nil || emailTextField.text!.isEmpty {
            
            errors.append(NSLocalizedString("Please set your email address!", comment: "Error message when email missing"))
        }
        else if !emailTextField.text!.validEmailFormat() {
            
            errors.append(NSLocalizedString("Please provide valid email!", comment: "Error message when email invalid"))
        }
        
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
            
            return false
        }
        
        return true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == signinSegueId {
            (segue.destination as! FTSigninWithEmailViewController).userName = sender as? String
        }
        
    }
    
}

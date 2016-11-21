//
//  FTOnboardingViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTOnboardingViewController: UIViewController {
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var tutorialButton: UIButton!
    
    fileprivate let tutorialSegueId = "tutorial"
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        FTAnalytics.trackEvent(.OnBoarding, data: nil)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(animated)
//        
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if FTDataManager.sharedInstance.currentUser != nil {
            
            dismiss(animated: true, completion: nil)
        }
        else if !FTTutorialMainViewController.isTutorialSeen() {
            
            performSegue(withIdentifier: tutorialSegueId, sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if let navController = navigationController {
            
            if navController.isNavigationBarHidden {
                navController.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    // MARK: - UI Customization
    
    fileprivate func setupReviewButton() {
        
        tutorialButton.setTitleColor(UIColor.white, for: UIControlState())
        tutorialButton.titleLabel?.font = UIFont.defaultFont(.bold, size: 14.7)
        tutorialButton.setTitle(NSLocalizedString("REVIEW TUTORIAL", comment: "Review tutorial button title"), for: UIControlState())
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        title = NSLocalizedString("420 Games", comment: "Onboarding screen title")
        
        facebookButton.ft_setupButton(UIColor.ftFacebookBlue(), title: NSLocalizedString("SIGN UP/IN WITH FACEBOOK", comment: "Facebook signup button title"))
        
        signinButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("LOG IN WITH EMAIL", comment: "Email signin button title"))
        
        setupReviewButton()
    }
    
    // MARK: - Actions

    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing up with Facebook", comment: "HUD title when signing up with Facebook")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.loginWithFacebook { (user, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if user != nil && error == nil {
                    
                    FTAnalytics.trackEvent(.SignIn, data: ["mode": "Facebook" as AnyObject])
                    
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: nil, message: "Failed to sign up or log in:(", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}

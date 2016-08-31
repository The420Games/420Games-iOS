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
    
    private let tutorialSegueId = "tutorial"
    
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
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if FTDataManager.sharedInstance.currentUser != nil {
            
            dismissViewControllerAnimated(true, completion: nil)
        }
        else if !FTTutorialMainViewController.isTutorialSeen() {
            
            performSegueWithIdentifier(tutorialSegueId, sender: self)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if let navController = navigationController {
            
            if navController.navigationBarHidden {
                navController.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    // MARK: - UI Customization
    
    private func setupReviewButton() {
        
        tutorialButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tutorialButton.titleLabel?.font = UIFont.defaultFont(.Bold, size: 14.7)
        tutorialButton.setTitle(NSLocalizedString("REVIEW TUTORIAL", comment: "Review tutorial button title"), forState: .Normal)
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        title = NSLocalizedString("420 Games", comment: "Onboarding screen title")
        
        facebookButton.ft_setupButton(UIColor.ftFacebookBlue(), title: NSLocalizedString("SIGN UP/IN WITH FACEBOOK", comment: "Facebook signup button title"))
        
        signinButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("LOG IN WITH EMAIL", comment: "Email signin button title"))
        
        setupReviewButton()
    }
    
    // MARK: - Actions

    @IBAction func facebookButtonPressed(sender: AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing up with Facebook", comment: "HUD title when signing up with Facebook")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.loginWithFacebook { (user, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
                if user != nil && error == nil {
                    
                    FTAnalytics.trackEvent(.SignIn, data: ["mode": "Facebook"])
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: nil, message: "Failed to sign up or log in:(", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}

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

    @IBAction func facebookButtonPressed(sender: AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("Signing up with Facebook", comment: "HUD title when signing up with Facebook")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.loginWithFacebook { (user, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hide(true)
                
                if user != nil && error == nil {
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

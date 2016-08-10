//
//  FTContainerViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class FTContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FTMainViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FTLeftMenuViewController") {
            self.leftViewController = controller
        }
        
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addLeftBarButtonWithImage(UIImage(named: "icon_menu")!)

        signupForSignoutNotification()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        removeFromSignoutNotification()
    }
    
    private func checkLoggedIn() {
        if FTDataManager.sharedInstance.currentUser == nil {
            performSegueWithIdentifier("onboarding", sender: self)
        }
    }

    private func signupForSignoutNotification() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.signoutNotificationReceived(_:)), name: FTSignedOutNotificationName, object: nil)
    }
    
    private func removeFromSignoutNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FTSignedOutNotificationName, object: nil)
    }
    
    func signoutNotificationReceived(notification: NSNotification) {
        
        checkLoggedIn()
    }
}

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
        
        SlideMenuOptions.leftViewWidth = 300
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FTHomeViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FTLeftMenuViewController") {
            self.leftViewController = controller
        }
        
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        self.addLeftBarButtonWithImage(UIImage(named: "icon_menu")!)
        
        navigationItem.title = NSLocalizedString("420 Games", comment: "Main screen title")

        signupForSignoutNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    fileprivate func checkLoggedIn() {
        if FTDataManager.sharedInstance.currentUser == nil {
            performSegue(withIdentifier: "onboarding", sender: self)
        }
    }

    fileprivate func signupForSignoutNotification() {

        NotificationCenter.default.addObserver(self, selector: #selector(self.signoutNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTSignedOutNotificationName), object: nil)
    }
    
    fileprivate func removeFromSignoutNotification() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTSignedOutNotificationName), object: nil)
    }
    
    func signoutNotificationReceived(_ notification: Notification) {
        
        checkLoggedIn()
    }
}

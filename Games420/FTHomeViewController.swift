//
//  FTHomeViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTHomeViewController: UIViewController {
    
    private let profileSegueId = "profile"
    
    // MARK: - Container Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        manageForMenuNotification(true)
        
        setupUI()
    }
    
    deinit {
        
        manageForMenuNotification(false)
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
    }

    // MARK: - Notifications
    
    private func manageForMenuNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.menuItemSelectedNotificationReceived(_:)), name: FTSlideMenuItemSelectedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTSlideMenuItemSelectedNotificationName, object: nil)
        }
    }
    
    func menuItemSelectedNotificationReceived(notification: NSNotification) {
        
        if let index = notification.userInfo?["itemIndex"] as? Int {
            
            if let item = FTSlideMenuItem(rawValue: index) {
                
                switch item {
                case .Profile: performSegueWithIdentifier(profileSegueId, sender: self)
                case .Main: navigationController?.popToRootViewControllerAnimated(true)
                default: print("Implement menu for \(item)")
                }
            }
        }
    }
}

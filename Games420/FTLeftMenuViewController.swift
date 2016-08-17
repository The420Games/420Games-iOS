//
//  FTLeftMenuViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

let FTSlideMenuItemSelectedNotificationName = "SlideMenuItemSelectedNotification"

enum FTSlideMenuItem: Int {
    case Main = 0, Workouts, Profile, FAQ, Terms, Tutorial
    static let count = 6
    
    func title() -> String {
        
        switch self {
        case .Main: return NSLocalizedString("HOME", comment: "Home menu item title")
        case .Workouts: return NSLocalizedString("WORKOUTS", comment: "Workouts menu item title")
        case .Profile: return NSLocalizedString("PROFILE", comment: "Profile menu item title")
        case .FAQ: return NSLocalizedString("FAQ", comment: "FAQ menu item title")
        case .Terms: return NSLocalizedString("TERMS & CONDITIONS", comment: "Terms menu item title")
        case .Tutorial: return NSLocalizedString("TUTORIAL", comment: "Tutorial menu item title")
        }
    }
    
    func icon() -> UIImage? {
        
        switch self {
        case .Main: return UIImage(named: "icon_home")
        case .Workouts: return UIImage(named: "icon_activities")
        case .Profile: return UIImage(named: "icon_settings")
        case .FAQ: return UIImage(named: "icon_faq")
        case .Terms: return UIImage(named: "icon_terms")
        case .Tutorial: return UIImage(named: "icon_tutorial")
        }
    }
}

class FTLeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userLocationLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var logoutLabel: UILabel!
    
    private let menuCellId = "menuCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        signupForUserUpdatedNotification()
        signupForLoginNotification()
        signupForProfileUpdatedNotification()
        
        populateUserData()
        
        fetchUserData()
    }
    
    deinit {
        
        resignFromUserUpdatedNotification()
        resignFromLoginNotification()
        resignFromProfileUpdatedNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customization
    
    private func setupTableView() {
        
        menuTableView.tableFooterView = UIView()
        menuTableView.backgroundColor = UIColor.clearColor()
    }
    
    private func setupHeader() {
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.ftLimeGreen().CGColor
        profileImageView.layer.borderWidth = 5.0
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        userNameLabel.font = UIFont.defaultFont(.Medium, size: 15.0)
        userNameLabel.textColor = UIColor.whiteColor()
        
        userLocationLabel.font = UIFont.defaultFont(.Light, size: 11)
        userLocationLabel.textColor = UIColor.whiteColor()
    }
    
    private func setupLogout() {
        
        logoutLabel.font = UIFont.defaultFont(.Bold, size: 15.0)
        logoutLabel.textColor = UIColor.ftMidGray2()
        logoutLabel.text = NSLocalizedString("LOG OUT", comment: "Logout label title")
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftAlmostBlack()
    
        setupTableView()
        
        setupHeader()
        
        setupLogout()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutTapped(sender: AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing out", comment: "HUD title when signingout")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.logout { (success, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                FTAnalytics.trackEvent(.SignOut, data: nil)
                
                hud.hideAnimated(true)
                
                self.slideMenuController()?.closeLeft()
                
                NSNotificationCenter.defaultCenter().postNotificationName(FTSignedOutNotificationName, object: self)
            })
        }
    }
    
    // MARK: - Data integration
    
    private func fetchUserData() {
        
        if let athleteId = FTDataManager.sharedInstance.currentUser?.athlete?.objectId {
            
            Athlete.findFirstObject("objectId = '\(athleteId)'", completion: { (object, error) in
                
                if error == nil && object != nil {
                    
                    FTDataManager.sharedInstance.currentUser?.athlete = object as? Athlete
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.populateUserData()
                    })
                }
            })
            
        }
    }
    
    private func populateUserData() {
        
        let defaultPhoto = UIImage(named: "default_photo")
        
        if let athlete = FTDataManager.sharedInstance.currentUser?.athlete {
            
            if let url = FTDataManager.sharedInstance.imageUrlForProperty(athlete.profileImage, path: Athlete.profileImagePath) {
                profileImageView.kf_setImageWithURL(url, placeholderImage: defaultPhoto , optionsInfo: .None, progressBlock: nil, completionHandler: nil)
            }
            else {
                profileImageView.image = defaultPhoto
            }
            
            userNameLabel.text = athlete.fullName()
            userLocationLabel.text = athlete.fullLocality()
        }
        else {
            profileImageView.image = defaultPhoto
            userNameLabel.text = NSLocalizedString("Name not set", comment: "Name placeholder")
            userLocationLabel.text = NSLocalizedString("Location not set", comment: "Location placeholder")
        }
    }
    
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FTSlideMenuItem.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(menuCellId, forIndexPath: indexPath) as! FTLeftMenuItemCell
        
        if let item = FTSlideMenuItem(rawValue: indexPath.row) {
            cell.setupCell(item.icon(), title: item.title(), lastItem: indexPath.row == FTSlideMenuItem.count - 1)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if let item = FTSlideMenuItem(rawValue: indexPath.row) {
            NSNotificationCenter.defaultCenter().postNotificationName(FTSlideMenuItemSelectedNotificationName, object: self, userInfo: ["itemIndex": item.rawValue])
            FTAnalytics.trackEvent(.MenuItemSelected, data: ["item": "\(item)"])
        }
        
        slideMenuController()?.closeLeft()
    }

    // MARK: - Notifications
    
    private func signupForUserUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: FTUserUpdatedNotificationName, object: nil)
    }
    
    private func resignFromUserUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FTUserUpdatedNotificationName, object: nil)
    }
    
    private func signupForProfileUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: FTProfileUpdatedNotificationName, object: nil)
    }
    
    private func resignFromProfileUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FTProfileUpdatedNotificationName, object: nil)
    }
    
    private func signupForLoginNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: FTSignedInNotificationName, object: nil)
    }
    
    private func resignFromLoginNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FTSignedInNotificationName, object: nil)
    }
    
    func userUpdatedNotificationReceived(notification: NSNotification) {
        
        populateUserData()
    }
}

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

// TODO: Change this to final
let FTTermsAndConditionsLink = "http://420games.org/"
let FTFAQLink = "http://420games.org/"

enum FTSlideMenuItem: Int {
    case main = 0, workouts, profile, faq, terms, tutorial
    static let count = 6
    
    func title() -> String {
        
        switch self {
        case .main: return NSLocalizedString("HOME", comment: "Home menu item title")
        case .workouts: return NSLocalizedString("WORKOUTS", comment: "Workouts menu item title")
        case .profile: return NSLocalizedString("PROFILE", comment: "Profile menu item title")
        case .faq: return NSLocalizedString("FAQ", comment: "FAQ menu item title")
        case .terms: return NSLocalizedString("TERMS & CONDITIONS", comment: "Terms menu item title")
        case .tutorial: return NSLocalizedString("TUTORIAL", comment: "Tutorial menu item title")
        }
    }
    
    func icon() -> UIImage? {
        
        switch self {
        case .main: return UIImage(named: "icon_home")
        case .workouts: return UIImage(named: "icon_activities")
        case .profile: return UIImage(named: "icon_settings")
        case .faq: return UIImage(named: "icon_faq")
        case .terms: return UIImage(named: "icon_terms")
        case .tutorial: return UIImage(named: "icon_tutorial")
        }
    }
}

class FTLeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userLocationLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var logoutLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    fileprivate let menuCellId = "menuCell"
    
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
    
    fileprivate func setupTableView() {
        
        menuTableView.tableFooterView = UIView()
        menuTableView.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupHeader() {
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.ftLimeGreen().cgColor
        profileImageView.layer.borderWidth = 5.0
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        userNameLabel.font = UIFont.defaultFont(.medium, size: 15.0)
        userNameLabel.textColor = UIColor.white
        
        userLocationLabel.font = UIFont.defaultFont(.light, size: 11)
        userLocationLabel.textColor = UIColor.white
    }
    
    fileprivate func setupLogout() {
        
        logoutLabel.font = UIFont.defaultFont(.bold, size: 15.0)
        logoutLabel.textColor = UIColor.ftMidGray2()
        logoutLabel.text = NSLocalizedString("LOG OUT", comment: "Logout label title")
    }
    
    fileprivate func setupVersionLabel() {
        
        versionLabel.textColor = UIColor.ftMidGray()
        versionLabel.font = UIFont.defaultFont(.light, size: 10.0)
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        versionLabel.text = "Games420 v\(version) (\(build)) \(FTDataManager.ftStaging ? " - Staging" : "")"
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftAlmostBlack()
    
        setupTableView()
        
        setupHeader()
        
        setupLogout()
        
        setupVersionLabel()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutTapped(_ sender: AnyObject) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing out", comment: "HUD title when signingout")
        hud.mode = .indeterminate
        
        FTDataManager.sharedInstance.logout { (success, error) in
            
            DispatchQueue.main.async(execute: {
                
                FTAnalytics.trackEvent(.SignOut, data: nil)
                
                hud.hide(animated: true)
                
                self.slideMenuController()?.closeLeft()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: FTSignedOutNotificationName), object: self)
            })
        }
    }
    
    // MARK: - Data integration
    
    fileprivate func fetchUserData() {
        
        if let athleteId = FTDataManager.sharedInstance.currentUser?.athlete?.objectId {
            
            Athlete.findFirstObject("objectId = '\(athleteId)'", completion: { (object, error) in
                
                if error == nil && object != nil {
                    
                    FTDataManager.sharedInstance.currentUser?.athlete = object as? Athlete
                    
                    DispatchQueue.main.async(execute: {
                        self.populateUserData()
                    })
                }
            })
            
        }
    }
    
    fileprivate func populateUserData() {
        
        let defaultPhoto = UIImage(named: "default_photo")
        
        if let athlete = FTDataManager.sharedInstance.currentUser?.athlete {
            
            if let url = FTDataManager.sharedInstance.imageUrlForProperty(athlete.profileImage, path: Athlete.profileImagePath) {
                
                profileImageView.kf.setImage(with: url, placeholder: defaultPhoto, options: .none, progressBlock: nil, completionHandler: nil)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FTSlideMenuItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: menuCellId, for: indexPath) as! FTLeftMenuItemCell
        
        if let item = FTSlideMenuItem(rawValue: indexPath.row) {
            cell.setupCell(item.icon(), title: item.title(), lastItem: indexPath.row == FTSlideMenuItem.count - 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let item = FTSlideMenuItem(rawValue: indexPath.row) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: FTSlideMenuItemSelectedNotificationName), object: self, userInfo: ["itemIndex": item.rawValue])
            FTAnalytics.trackEvent(.MenuItemSelected, data: ["item": "\(item)" as AnyObject])
        }
        
        slideMenuController()?.closeLeft()
    }

    // MARK: - Notifications
    
    fileprivate func signupForUserUpdatedNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTUserUpdatedNotificationName), object: nil)
    }
    
    fileprivate func resignFromUserUpdatedNotification() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTUserUpdatedNotificationName), object: nil)
    }
    
    fileprivate func signupForProfileUpdatedNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTProfileUpdatedNotificationName), object: nil)
    }
    
    fileprivate func resignFromProfileUpdatedNotification() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTProfileUpdatedNotificationName), object: nil)
    }
    
    fileprivate func signupForLoginNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTSignedInNotificationName), object: nil)
    }
    
    fileprivate func resignFromLoginNotification() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTSignedInNotificationName), object: nil)
    }
    
    func userUpdatedNotificationReceived(_ notification: Notification) {
        
        populateUserData()
    }
}

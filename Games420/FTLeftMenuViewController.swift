//
//  FTLeftMenuViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import Kingfisher

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
        
        fetchUserData()
    }
    
    deinit {
        
        resignFromUserUpdatedNotification()
        resignFromLoginNotification()
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
        profileImageView.layer.borderWidth = 13.0
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
    }
    
    @IBAction func profileTapped(sender: AnyObject) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Data integration
    
    private func fetchUserData() {
        
        populateUserData()
    }
    
    private func populateUserData() {
        
        if let athlete = FTDataManager.sharedInstance.currentUser?.athlete {
            
            if let url = FTDataManager.sharedInstance.imageUrlForProperty(athlete.profileImage, path: Athlete.profileImagePath) {
                profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "default_photo") , optionsInfo: .None, progressBlock: nil, completionHandler: nil)
            }
            
            userNameLabel.text = athlete.fullName()
            userLocationLabel.text = athlete.fullLocality()
        }
    }
    
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(menuCellId, forIndexPath: indexPath)
        
        return cell
    }

    // MARK: - Notifications
    
    private func signupForUserUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userUpdatedNotificationReceived(_:)), name: FTUserUpdatedNotificationName, object: nil)
    }
    
    private func resignFromUserUpdatedNotification() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FTUserUpdatedNotificationName, object: nil)
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

//
//  FTSelectActivityViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTSelectActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activitiesTableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    
    private var activities = [Activity]()
    
    private let activityCellid = "activityCell"
    
    private let pageSize = 20
    private var pageOffset = 0
    private var moreAvailable = false
    private var isFetching = false
        
    var activitySelected: ((activity: Activity!) -> ())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        fetchActivities()
        
        FTAnalytics.trackEvent(.ActivityPicker, data: ["source": "Strava"])
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        title = NSLocalizedString("Select activity", comment: "Select activity title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupTablewView()
    }
    
    private func setupTablewView() {
        
        activitiesTableView.tableFooterView = UIView()
        
        activitiesTableView.backgroundColor = UIColor.clearColor()
        activitiesTableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.ftLimeGreen()
        refreshControl.addTarget(self, action: #selector(self.refreshValueChanged(_:)), forControlEvents: .ValueChanged)
        activitiesTableView.addSubview(refreshControl)
    }
    
    // MARK: - Actions
    
    func backButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshValueChanged(sender: AnyObject) {
        
        pageOffset = 0
        fetchActivities()
    }
    
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(activityCellid, forIndexPath: indexPath) as! FTSelectActivityCell
        
        let activity = activities[indexPath.row]
        
        cell.setupWithActivity(activity, lastItem: indexPath.row == activities.count - 1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == activities.count - 1 {
            fetchActivities()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        FTAnalytics.trackEvent(.SelectActivity, data: nil)
        
        activitySelected?(activity: activities[indexPath.row])
    }
    
    // MARK: - API integration
    
    private func fetchActivities() {
        
        if !isFetching && (pageOffset == 0 || moreAvailable) {
            
            isFetching = true
            
            var hud: MBProgressHUD?
            if pageOffset == 0 {
                hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud!.label.text = NSLocalizedString("Fetching Strava Activities", comment: "HUD title when fetching activities from strava")
                hud!.mode = .Indeterminate
            }
        
            FTStravaManager.sharedInstance.fetchActivities(pageOffset, pageSize: pageSize, completion: { (results, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.isFetching = false
         
                    if hud != nil {
                        hud!.hideAnimated(true)
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                    if results != nil {
                        
                        if self.pageOffset == 0 {
                            self.activities.removeAll()
                        }
                        
                        self.pageOffset += 1
                        self.moreAvailable = results!.count >= self.pageSize
                        
                        self.activities.appendContentsOf(results!)
                        self.activitiesTableView.reloadData()
                    }                    
                })
            })
        }
    }

}

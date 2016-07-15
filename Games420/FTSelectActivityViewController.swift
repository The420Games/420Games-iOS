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
    
    private var activities: [Activity]?
    
    var activitySelected: ((activity: Activity!) -> ())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Select activity", comment: "Select activity title")
        
        setupTablewView()
        
        addCancelButton()
        
        fetchActivities()
    }
    
    // MARK: - UI Customization
    
    private func addCancelButton() {
        
        let cancelItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .Plain, target: self, action: #selector(self.cancelPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = cancelItem
    }
    
    private func setupTablewView() {
        
        activitiesTableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions
    
    func cancelPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities != nil ? activities!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath) as! FTSelectActivityCell
        
        let activity = activities![indexPath.row]
        
        cell.setupWithActivity(activity)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        activitySelected?(activity: activities![indexPath.row])
    }
    
    // MARK: - API integration
    
    private func fetchActivities() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("Fetching Strava Activities", comment: "HUD title when fetching activities from strava")
        hud.mode = .Indeterminate
        
        FTStravaManager.sharedInstance.fetchActivities({ (results, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hide(true)
                
                if results != nil {
                    self.activities = results
                    self.activitiesTableView.reloadData()
                }
            })
        })
    }

}

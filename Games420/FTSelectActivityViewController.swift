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
    
    fileprivate var refreshControl: UIRefreshControl!
    
    fileprivate var activities = [Activity]()
    
    fileprivate let activityCellid = "activityCell"
    
    fileprivate let pageSize = 20
    fileprivate var pageOffset = 0
    fileprivate var moreAvailable = false
    fileprivate var isFetching = false
        
    var activitySelected: ((_ activity: Activity?) -> ())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        fetchActivities()
        
        FTAnalytics.trackEvent(.ActivityPicker, data: ["source": "Strava" as AnyObject])
    }
    
    // MARK: - UI Customization
    
    fileprivate func setupUI() {
        
        title = NSLocalizedString("Select activity", comment: "Select activity title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupTablewView()
    }
    
    fileprivate func setupTablewView() {
        
        activitiesTableView.tableFooterView = UIView()
        
        activitiesTableView.backgroundColor = UIColor.clear
        activitiesTableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.ftLimeGreen()
        refreshControl.addTarget(self, action: #selector(self.refreshValueChanged(_:)), for: .valueChanged)
        activitiesTableView.addSubview(refreshControl)
    }
    
    // MARK: - Actions
    
    func backButtonPressed(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func refreshValueChanged(_ sender: AnyObject) {
        
        pageOffset = 0
        fetchActivities()
    }
    
    // MARK: - Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: activityCellid, for: indexPath) as! FTSelectActivityCell
        
        let activity = activities[indexPath.row]
        
        cell.setupWithActivity(activity, lastItem: indexPath.row == activities.count - 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == activities.count - 1 {
            fetchActivities()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        FTAnalytics.trackEvent(.SelectActivity, data: nil)
        
        activitySelected?(activities[indexPath.row])
    }
    
    // MARK: - API integration
    
    fileprivate func fetchActivities() {
        
        if !isFetching && (pageOffset == 0 || moreAvailable) {
            
            isFetching = true
            
            var hud: MBProgressHUD?
            if pageOffset == 0 {
                hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud!.label.text = NSLocalizedString("Fetching Strava Activities", comment: "HUD title when fetching activities from strava")
                hud!.mode = .indeterminate
            }
        
            FTStravaManager.sharedInstance.fetchActivities(pageOffset, pageSize: pageSize, completion: { (results, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    self.isFetching = false
         
                    if hud != nil {
                        hud!.hide(animated: true)
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                    if results != nil {
                        
                        if self.pageOffset == 0 {
                            self.activities.removeAll()
                        }
                        
                        self.pageOffset += 1
                        self.moreAvailable = results!.count >= self.pageSize
                        
                        self.activities.append(contentsOf: results!)
                        self.activitiesTableView.reloadData()
                    }                    
                })
            })
        }
    }

}

//
//  ViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logActivityButton: UIButton!
    
    @IBOutlet weak var activitiesTableView: UITableView!
    
    private var medications: [Medication]?
    
    private var waitingForStravaAuthentication = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTableView()
        
        manageForStravaNotification(true)
        
    }
    
    deinit {
        manageForStravaNotification(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if FTDataManager.sharedInstance.currentUser != nil {
            fetchMedications()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTouched(sender: AnyObject) {
        
        if !FTStravaManager.sharedInstance.isAuthorized {
            waitingForStravaAuthentication = true
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            hud.mode = .Indeterminate
            
            FTStravaManager.sharedInstance.authorize("games420://games420")
        }
        else {
            performSegueWithIdentifier("activities", sender: self)
        }
    }
    
    @IBAction func signoutPressed(sender: AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("Signing out", comment: "HUD title when signingout")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.logout { (success, error) in
            dispatch_async(dispatch_get_main_queue(), {
                hud.hide(true)
                
                self.checkLoggedIn()
            })
        }
        
    }
    
    private func checkLoggedIn() {
        if FTDataManager.sharedInstance.currentUser == nil {
            performSegueWithIdentifier("onboarding", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "activities" {
            ((segue.destinationViewController as! UINavigationController).viewControllers[0] as! FTSelectActivityViewController).activitySelected = {(activity) -> () in
                self.dismissViewControllerAnimated(true, completion: {
                    print("selected activiy: \(activity)")
                    self.performSegueWithIdentifier("logActivity", sender: activity)
                });
            }
        }
        else if segue.identifier == "logActivity" {
            (segue.destinationViewController as! FTLogActivityViewController).activity = sender as? Activity
        }
    }
    
    // MARK: - UI Customizations
    
    private func setupTableView() {
        
        activitiesTableView.tableFooterView = UIView()
    }

    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medications != nil ? medications!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("medicationCell", forIndexPath: indexPath) as! FTMedicationCell
        
        let medication = medications![indexPath.row]
        
        cell.setupWithMedication(medication)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: - Notifications
    
    private func manageForStravaNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stravaNotificationReceived(_:)), name: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: nil)
        }
    }
    
    func stravaNotificationReceived(notification: NSNotification) {

        if waitingForStravaAuthentication {
            
            waitingForStravaAuthentication = false
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if let success = notification.userInfo?["success"] as? Bool {
                if success {
                    performSegueWithIdentifier("activities", sender: self)
                }
            }
        }
    }

    // MARK: - Backend integration
    
    private func fetchMedications() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("Fetching Activities", comment: "HUD title when fetching activities")
        hud.mode = .Indeterminate
        
        Medication.findObjects("ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'", order: ["updated desc"]) { (objects, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hide(true)
                
                if objects != nil {
                    self.medications = objects as? [Medication]
                    self.activitiesTableView.reloadData()
                }
                else {
                    print("Error fetching Medications: \(error)")
                }
            })
        }
    }
}


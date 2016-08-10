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
    private var stravaAuthenticationHUD: MBProgressHUD?
    
    private let medicationDetailSegueId = "medicationDetail"
    private let activityEditSegueId = "manualTrack"
    private let medicationEditSegueId = "logActivity"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTableView()
        
        manageForStravaNotification(true)
        
        title = NSLocalizedString("Logged activities", comment: "Main screen navigation title")
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
        
        let picker = UIAlertController(title: NSLocalizedString("Source", comment: "Select source title"), message: NSLocalizedString("Select tracker app you logged your activity with", comment: "Message source"), preferredStyle: .ActionSheet)
        
        picker.addAction(UIAlertAction(title: "Strava", style: .Default, handler: { (action) in
            self.logActivityWithStrava()
        }))
        
//        picker.addAction(UIAlertAction(title: "RunKeeper", style: .Default, handler: nil))
//        picker.addAction(UIAlertAction(title: "Endomondo", style: .Default, handler: nil))
//        picker.addAction(UIAlertAction(title: "RunTastic", style: .Default, handler: nil))
        
        picker.addAction(UIAlertAction(title: NSLocalizedString("Manual", comment: "Manually add a track"), style: .Default, handler: { (action) in
            self.performSegueWithIdentifier(self.activityEditSegueId, sender: self)
        }))
        
        picker.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func signoutPressed(sender: AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing out", comment: "HUD title when signingout")
        hud.mode = .Indeterminate
        
        FTDataManager.sharedInstance.logout { (success, error) in
            dispatch_async(dispatch_get_main_queue(), {
                hud.hideAnimated(true)
                
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
                    self.performSegueWithIdentifier(self.medicationEditSegueId, sender: activity)
                });
            }
        }
        else if segue.identifier == medicationDetailSegueId {
            (segue.destinationViewController as! FTMedicationDetailsViewController).medication = sender as! Medication
        }
        else if segue.identifier == medicationEditSegueId {
            let target = segue.destinationViewController as! FTLogActivityViewController
            if let activity = sender as? Activity {
                target.activity = activity
            }
            else if let medication = sender as? Medication {
                target.medication = medication
                target.activity = medication.activity
            }
        }
        else if segue.identifier == activityEditSegueId {
            let target = segue.destinationViewController as! FTManualActivityTrackViewController
            let medication = sender as! Medication
            target.activity = medication.activity
            target.medication = medication
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
        
        let medication = medications![indexPath.row]
        performSegueWithIdentifier(medicationDetailSegueId, sender: medication)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .Default, title: NSLocalizedString("Delete", comment: "Delete action title")) { (action, indexpath) in
            
            let medication = self.medications![indexPath.row]
            self.deleteMedication(medication)
        }
        
        let editAction = UITableViewRowAction(style: .Normal, title: NSLocalizedString("Edit", comment: "Edit action title")) { (action, indexpath) in
            
            let medication = self.medications![indexPath.row]
            self.editMedication(medication)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //
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
            
            if stravaAuthenticationHUD != nil {
                stravaAuthenticationHUD!.hideAnimated(true)
                stravaAuthenticationHUD = nil
            }
            
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
        hud.label.text = NSLocalizedString("Fetching Activities", comment: "HUD title when fetching activities")
        hud.mode = .Indeterminate
        
        Medication.findObjects("ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'", order: ["updated desc"]) { (objects, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
                
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
    
    private func deleteMedication(medication: Medication) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Deleting Medication", comment: "HUD title when deleting a medication")
        hud.mode = .Indeterminate
        
        let group = dispatch_group_create();
        
        if medication.activity != nil {
            
            dispatch_group_enter(group)
            
            medication.activity!.deleteInBackgroundWithBlock({ (success, error) in
                
                if error != nil {
                    print("Error deleting activity: \(error)")
                }
                
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
        
            medication.deleteInBackgroundWithBlock { (success, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    hud.hideAnimated(true)
                    
                    if success {
                        
                        if let index = self.medications!.indexOf(medication) {
                            self.medications?.removeAtIndex(index)
                            self.activitiesTableView.beginUpdates()
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.activitiesTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                            self.activitiesTableView.endUpdates()
                        }
                        else {
                            self.fetchMedications()
                        }
                    }
                    else {
                        if self.activitiesTableView.editing {
                            self.activitiesTableView.setEditing(false, animated: false)
                        }
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to delete medication:(", comment: "Error message when failed to delete medication"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    private func editMedication(medication: Medication) {
        
        if medication.activity != nil && medication.activity!.source != nil {
            performSegueWithIdentifier(medicationEditSegueId, sender: medication)
        }
        else {
            performSegueWithIdentifier(activityEditSegueId, sender: medication)
        }
    }
    
    // MARK: - Apps integrations
    
    func logActivityWithStrava() {
        
        if !FTStravaManager.sharedInstance.isAuthorized {
            waitingForStravaAuthentication = true
            
            stravaAuthenticationHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            stravaAuthenticationHUD!.label.text = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            stravaAuthenticationHUD!.mode = .Indeterminate
            
            FTStravaManager.sharedInstance.authorize("games420://games420")
        }
        else {
            performSegueWithIdentifier("activities", sender: self)
        }
    }
}


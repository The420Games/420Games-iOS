//
//  FTMedicationsViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTMedicationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addMedicationButton: UIButton!
    
    @IBOutlet weak var medicationsTableView: UITableView!
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    private var medications = [Medication]()
    
    private var waitingForStravaAuthentication = false
    private var stravaAuthenticationHUD: MBProgressHUD?

    private let medicationCellId = "medicationCell"
    private let medicationDetailSegueId = "medicationDetail"
    private let activityEditSegueId = "manualTrack"
    private let medicationEditSegueId = "logActivity"
    
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        manageForStravaNotification(true)
        
        fetchMedications()
    }
    
    // MARK: - UI Customization
    
    private func setupTableView() {
        
        medicationsTableView.backgroundColor = UIColor.clearColor()
        medicationsTableView.tableFooterView = UIView()
    }
    
    private func setupFilter() {
        
        filterSegmentedControl.tintColor = UIColor.ftLimeGreen()
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.Bold, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ], forState: .Selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ], forState: .Normal)
        
        filterSegmentedControl.removeAllSegments()
        
        filterSegmentedControl.insertSegmentWithTitle(NSLocalizedString("ALL", comment: "All medications filter title"), atIndex: 0, animated: false)
        
        for type in ActivityType.allValues {
            
            var title: String!
            switch type {
            case .Ride: title = NSLocalizedString("BIKE RIDE", comment: "Bike ride title")
            case .Run: title = NSLocalizedString("RUNNING", comment: "Running title")
            case .Swim: title = NSLocalizedString("SWIMMING", comment: "Swimming title")
            default: title = "\(title)"
            }
            
            filterSegmentedControl.insertSegmentWithTitle(title, atIndex: filterSegmentedControl.numberOfSegments, animated: false)
        }
        
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Medications", comment: "Medications navigation item title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        setupTableView()
        
        setupFilter()
        
        filterSegmentedControl.selectedSegmentIndex = 0
        
        addMedicationButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("ADD NEW ACTIVITY", comment: "Add new medication button title"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func addMedicationTouched(sender: AnyObject) {
    }
    
    @IBAction func filterChanged(sender: UISegmentedControl) {
    }
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(medicationCellId, forIndexPath: indexPath) as! FTMedicationListCell
        
        let medication = medications[indexPath.row]
        
        cell.setupCell(medication)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let medication = medications[indexPath.row]
        performSegueWithIdentifier(medicationDetailSegueId, sender: medication)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .Default, title: NSLocalizedString("Delete", comment: "Delete action title")) { (action, indexpath) in
            
            let medication = self.medications[indexPath.row]
            self.deleteMedication(medication)
        }
        
        let editAction = UITableViewRowAction(style: .Normal, title: NSLocalizedString("Edit", comment: "Edit action title")) { (action, indexpath) in
            
            let medication = self.medications[indexPath.row]
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
                    self.medications.removeAll()
                    self.medications.appendContentsOf(objects as! [Medication])
                    self.medicationsTableView.reloadData()
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
                        
                        if let index = self.medications.indexOf(medication) {
                            self.medications.removeAtIndex(index)
                            self.medicationsTableView.beginUpdates()
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.medicationsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                            self.medicationsTableView.endUpdates()
                        }
                        else {
                            self.fetchMedications()
                        }
                    }
                    else {
                        if self.medicationsTableView.editing {
                            self.medicationsTableView.setEditing(false, animated: false)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

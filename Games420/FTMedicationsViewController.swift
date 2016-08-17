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
    
    private var refreshControl: UIRefreshControl!
    
    private var medications = [Medication]()
    
    private var waitingForStravaAuthentication = false
    private var stravaAuthenticationHUD: MBProgressHUD?
    
    private var activityType: ActivityType? = nil

    private let medicationCellId = "medicationCell"
    private let medicationDetailSegueId = "medicationDetail"
    private let activityEditSegueId = "manualTrack"
    private let medicationEditSegueId = "logActivity"
    private let selectActivitySegueId = "selectActivity"
    
    private let pageSize = 20
    private var pageOffset = 0
    private var moreAvailable = false
    private var isFetching = false
    
    var shouldAddNewActivityOnShow = false
    private var wasAddingMedicaton = false
    
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        manageForStravaNotification(true)
        
        manageForMedicationNotification(true)
        
        if !shouldAddNewActivityOnShow {
            fetchMedications()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if medicationsTableView.editing {
            medicationsTableView.setEditing(false, animated: false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if shouldAddNewActivityOnShow {
            
            shouldAddNewActivityOnShow = false
            wasAddingMedicaton = true
            
            addMedication()
        }
        else if medications.count == 0 {
            
            fetchMedications()
        }
    }
    
    deinit {
        
        manageForStravaNotification(false)
        manageForMedicationNotification(false)
    }
    
    // MARK: - UI Customization
    
    private func setupTableView() {
        
        medicationsTableView.backgroundColor = UIColor.clearColor()
        medicationsTableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.ftLimeGreen()
        refreshControl.addTarget(self, action: #selector(self.refreshValueChanged(_:)), forControlEvents: .ValueChanged)
        medicationsTableView.addSubview(refreshControl)
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
            
            let title = type.localizedName(false).uppercaseString
            
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
    
    func refreshValueChanged(sender: AnyObject) {
        
        pageOffset = 0
        fetchMedications()
    }
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func addMedicationTouched(sender: AnyObject) {
        
        addMedication()
    }
    
    @IBAction func filterChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            
            activityType = nil
        }
        else {
            if sender.selectedSegmentIndex < ActivityType.allValues.count {
                
                activityType = ActivityType.allValues[sender.selectedSegmentIndex - 1]
            }
            else {
                activityType = nil
            }
        }
        
        pageOffset = 0
        fetchMedications()
    }
    
    private func addMedication() {
        
        let picker = UIAlertController(title: NSLocalizedString("Source", comment: "Select source title"), message: NSLocalizedString("Select tracker app you logged your activity with", comment: "Message source"), preferredStyle: .ActionSheet)
        
        picker.addAction(UIAlertAction(title: "Strava", style: .Default, handler: { (action) in
            self.wasAddingMedicaton = false
            self.logActivityWithStrava()
        }))
        
        //        picker.addAction(UIAlertAction(title: "RunKeeper", style: .Default, handler: nil))
        //        picker.addAction(UIAlertAction(title: "Endomondo", style: .Default, handler: nil))
        //        picker.addAction(UIAlertAction(title: "RunTastic", style: .Default, handler: nil))
        
        picker.addAction(UIAlertAction(title: NSLocalizedString("Manual", comment: "Manually add a track"), style: .Default, handler: { (action) in
            self.wasAddingMedicaton = false
            self.performSegueWithIdentifier(self.activityEditSegueId, sender: self)
        }))
        
        picker.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            if self.medications.count == 0 && self.wasAddingMedicaton {
                self.wasAddingMedicaton = false
                self.fetchMedications()
            }
        }))
        
        presentViewController(picker, animated: true, completion: nil)
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
        
        cell.setupCell(medication, lastItem: indexPath.row == medications.count - 1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let medication = medications[indexPath.row]
        performSegueWithIdentifier(medicationDetailSegueId, sender: medication)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == medications.count - 1 {
            fetchMedications()
        }
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
                    performSegueWithIdentifier(selectActivitySegueId, sender: self)
                }
            }
        }
    }
    
    private func manageForMedicationNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.medicationSavedNotificationReceived(_:)), name: FTMedicationSavedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTMedicationSavedNotificationName, object: nil)
        }
    }
    
    func medicationSavedNotificationReceived(notification: NSNotification) {
        
        fetchMedications()
    }
    
    // MARK: - Backend integration
    
    private func fetchMedications() {
        
        if !isFetching && (pageOffset == 0 || moreAvailable) {
        
            isFetching = true
            
            var hud: MBProgressHUD?
            if pageOffset == 0 {
                hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud!.label.text = NSLocalizedString("Fetching Activities", comment: "HUD title when fetching activities")
                hud!.mode = .Indeterminate
            }
            
            var query = "ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'"
            
            if activityType != nil {
                query += " AND activity.Type = '\(activityType!.rawValue)'"
            }
            
            Medication.findObjects(query, order: ["updated desc"], offset: pageOffset * pageSize, limit: pageSize) { (objects, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.isFetching = false
                    
                    if hud != nil {
                        hud!.hideAnimated(true)
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                    if objects != nil {
                        
                        if self.pageOffset == 0 {
                            self.medications.removeAll()
                        }
                        self.medications.appendContentsOf(objects as! [Medication])
                        self.medicationsTableView.reloadData()
                        
                        self.pageOffset += 1
                        
                        self.moreAvailable = objects!.count >= self.pageSize
                    }
                    else {
                        print("Error fetching Medications: \(error)")
                    }
                })
            }
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
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(FTMedicationDeletedNotificationName, object: self)
                        
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
            performSegueWithIdentifier(selectActivitySegueId, sender: self)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if medicationsTableView.editing {
            medicationsTableView.setEditing(false, animated: true)
        }
        
        if segue.identifier == selectActivitySegueId {
            ((segue.destinationViewController as! UINavigationController).viewControllers.first as! FTSelectActivityViewController).activitySelected = {(activity) -> () in
                
                self.dismissViewControllerAnimated(true, completion: {
                    
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
            let medication = sender as? Medication
            target.activity = medication?.activity
            target.medication = medication
        }
    }

}

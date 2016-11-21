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
    
    fileprivate var refreshControl: UIRefreshControl!
    
    fileprivate var medications = [Medication]()
    
    fileprivate var waitingForStravaAuthentication = false
    fileprivate var stravaAuthenticationHUD: MBProgressHUD?
    
    fileprivate var activityType: ActivityType? = nil

    fileprivate let medicationCellId = "medicationCell"
    fileprivate let medicationDetailSegueId = "medicationDetail"
    fileprivate let activityEditSegueId = "manualTrack"
    fileprivate let medicationEditSegueId = "logActivity"
    fileprivate let selectActivitySegueId = "selectActivity"
    
    fileprivate let pageSize = 20
    fileprivate var pageOffset = 0
    fileprivate var moreAvailable = false
    fileprivate var isFetching = false
    
    var shouldAddNewActivityOnShow = false
    fileprivate var wasAddingMedicaton = false
    
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        manageForStravaNotification(true)
        
        manageForMedicationNotification(true)
        
        if !shouldAddNewActivityOnShow {
            fetchMedications()
        }
        
        FTAnalytics.trackEvent(.Medications, data: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if medicationsTableView.isEditing {
            medicationsTableView.setEditing(false, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    fileprivate func setupTableView() {
        
        medicationsTableView.backgroundColor = UIColor.clear
        medicationsTableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.ftLimeGreen()
        refreshControl.addTarget(self, action: #selector(self.refreshValueChanged(_:)), for: .valueChanged)
        medicationsTableView.addSubview(refreshControl)
    }
    
    fileprivate func setupFilter() {
        
        filterSegmentedControl.tintColor = UIColor.ftLimeGreen()
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.bold, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.white
            ], for: .selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.light, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.white
            ], for: UIControlState())
        
        filterSegmentedControl.removeAllSegments()
        
        filterSegmentedControl.insertSegment(withTitle: NSLocalizedString("ALL", comment: "All medications filter title"), at: 0, animated: false)
        
        for type in ActivityType.allValues {
            
            let title = type.localizedName(false).uppercased()
            
            filterSegmentedControl.insertSegment(withTitle: title, at: filterSegmentedControl.numberOfSegments, animated: false)
        }
        
    }
    
    fileprivate func setupUI() {
        
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
    
    func refreshValueChanged(_ sender: AnyObject) {
        
        pageOffset = 0
        fetchMedications()
    }
    
    func backButtonPressed(_ sender: AnyObject) {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addMedicationTouched(_ sender: AnyObject) {
        
        addMedication()
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        
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
        
        FTAnalytics.trackEvent(.MedicationsFilterChange, data: ["filter": sender.titleForSegment(at: sender.selectedSegmentIndex)! as AnyObject])
        
        pageOffset = 0
        fetchMedications()
    }
    
    fileprivate func addMedication() {
        
        let picker = UIAlertController(title: NSLocalizedString("Source", comment: "Select source title"), message: NSLocalizedString("Select tracker app you logged your activity with", comment: "Message source"), preferredStyle: .actionSheet)
        
        picker.addAction(UIAlertAction(title: "Strava", style: .default, handler: { (action) in
            self.wasAddingMedicaton = false
            self.logActivityWithStrava()
            FTAnalytics.trackEvent(.NewMedication, data: ["source": "Strava" as AnyObject])
        }))
        
        //        picker.addAction(UIAlertAction(title: "RunKeeper", style: .Default, handler: nil))
        //        picker.addAction(UIAlertAction(title: "Endomondo", style: .Default, handler: nil))
        //        picker.addAction(UIAlertAction(title: "RunTastic", style: .Default, handler: nil))
        
        picker.addAction(UIAlertAction(title: NSLocalizedString("Manual", comment: "Manually add a track"), style: .default, handler: { (action) in
            self.wasAddingMedicaton = false
            self.performSegue(withIdentifier: self.activityEditSegueId, sender: self)
            FTAnalytics.trackEvent(.NewMedication, data: ["source": "Manual" as AnyObject])
        }))
        
        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            if self.medications.count == 0 && self.wasAddingMedicaton {
                self.wasAddingMedicaton = false
                self.fetchMedications()
            }
        }))
        
        picker.view.tintColor = UIColor.ftLimeGreen()
        
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: medicationCellId, for: indexPath) as! FTMedicationListCell
        
        let medication = medications[indexPath.row]
        
        cell.setupCell(medication, lastItem: indexPath.row == medications.count - 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let medication = medications[indexPath.row]
        performSegue(withIdentifier: medicationDetailSegueId, sender: medication)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == medications.count - 1 {
            fetchMedications()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete action title")) { (action, indexpath) in
            
            let medication = self.medications[indexPath.row]
            self.deleteMedication(medication)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "Edit action title")) { (action, indexpath) in
            
            let medication = self.medications[indexPath.row]
            self.editMedication(medication)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
    
    // MARK: - Notifications
    
    fileprivate func manageForStravaNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.stravaNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: nil)
        }
    }
    
    func stravaNotificationReceived(_ notification: Notification) {
        
        if waitingForStravaAuthentication {
            
            waitingForStravaAuthentication = false
            
            if stravaAuthenticationHUD != nil {
                stravaAuthenticationHUD!.hide(animated: true)
                stravaAuthenticationHUD = nil
            }
            
            if let success = notification.userInfo?["success"] as? Bool {
                if success {
                    performSegue(withIdentifier: selectActivitySegueId, sender: self)
                }
            }
        }
    }
    
    fileprivate func manageForMedicationNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.medicationSavedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTMedicationSavedNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTMedicationSavedNotificationName), object: nil)
        }
    }
    
    func medicationSavedNotificationReceived(_ notification: Notification) {
        
        fetchMedications()
    }
    
    // MARK: - Backend integration
    
    fileprivate func fetchMedications() {
        
        if !isFetching && (pageOffset == 0 || moreAvailable) {
        
            isFetching = true
            
            var hud: MBProgressHUD?
            if pageOffset == 0 {
                hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud!.label.text = NSLocalizedString("Fetching Activities", comment: "HUD title when fetching activities")
                hud!.mode = .indeterminate
            }
            
            var query = "ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'"
            
            if activityType != nil {
                query += " AND activity.Type = '\(activityType!.rawValue)'"
            }
            
            Medication.findObjects(query, order: ["updated desc" as AnyObject], offset: pageOffset * pageSize, limit: pageSize) { (objects, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    self.isFetching = false
                    
                    if hud != nil {
                        hud!.hide(animated: true)
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                    if objects != nil {
                        
                        if self.pageOffset == 0 {
                            self.medications.removeAll()
                        }
                        self.medications.append(contentsOf: objects as! [Medication])
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
    
    fileprivate func deleteMedication(_ medication: Medication) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Deleting Medication", comment: "HUD title when deleting a medication")
        hud.mode = .indeterminate
        
        let group = DispatchGroup();
        
        if medication.activity != nil {
            
            group.enter()
            
            medication.activity!.deleteInBackgroundWithBlock({ (success, error) in
                
                if error != nil {
                    print("Error deleting activity: \(error)")
                }
                
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            medication.deleteInBackgroundWithBlock { (success, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    hud.hide(animated: true)
                    
                    if success {
                        
                        FTAnalytics.trackEvent(.DeleteMedication, data: nil)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: FTMedicationDeletedNotificationName), object: self)
                        
                        if let index = self.medications.index(of: medication) {
                            self.medications.remove(at: index)
                            self.medicationsTableView.beginUpdates()
                            let indexPath = IndexPath(row: index, section: 0)
                            self.medicationsTableView.deleteRows(at: [indexPath], with: .top)
                            self.medicationsTableView.endUpdates()
                        }
                        else {
                            self.fetchMedications()
                        }
                    }
                    else {
                        if self.medicationsTableView.isEditing {
                            self.medicationsTableView.setEditing(false, animated: false)
                        }
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to delete medication:(", comment: "Error message when failed to delete medication"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    fileprivate func editMedication(_ medication: Medication) {
        
        FTAnalytics.trackEvent(.EditMedication, data: nil)
        
        if medication.activity != nil && medication.activity!.source != nil {
            performSegue(withIdentifier: medicationEditSegueId, sender: medication)
        }
        else {
            performSegue(withIdentifier: activityEditSegueId, sender: medication)
        }
    }
    
    // MARK: - Apps integrations
    
    func logActivityWithStrava() {
        
        if !FTStravaManager.sharedInstance.isAuthorized {
            waitingForStravaAuthentication = true
            
            stravaAuthenticationHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            stravaAuthenticationHUD!.label.text = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            stravaAuthenticationHUD!.mode = .indeterminate
            
            FTStravaManager.sharedInstance.authorize("games420://games420")
        }
        else {
            performSegue(withIdentifier: selectActivitySegueId, sender: self)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if medicationsTableView.isEditing {
            medicationsTableView.setEditing(false, animated: true)
        }
        
        if segue.identifier == selectActivitySegueId {
            ((segue.destination as! UINavigationController).viewControllers.first as! FTSelectActivityViewController).activitySelected = {(activity) -> () in
                
                self.dismiss(animated: true, completion: {
                    
                    self.performSegue(withIdentifier: self.medicationEditSegueId, sender: activity)
                });
            }
        }
        else if segue.identifier == medicationDetailSegueId {
            (segue.destination as! FTMedicationDetailsViewController).medication = sender as! Medication
        }
        else if segue.identifier == medicationEditSegueId {
            let target = segue.destination as! FTLogActivityViewController
            if let activity = sender as? Activity {
                target.activity = activity
            }
            else if let medication = sender as? Medication {
                target.medication = medication
                target.activity = medication.activity
            }
        }
        else if segue.identifier == activityEditSegueId {
            let target = segue.destination as! FTManualActivityTrackViewController
            let medication = sender as? Medication
            target.activity = medication?.activity
            target.medication = medication
        }
    }

}

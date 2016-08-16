//
//  FTMedicationDetailsViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTMedicationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var medication: Medication!
    
    private let cellId = "medicationCell"
    
    enum FTMedicationDetailSection: Int {
        case activity = 0, medication
        
        func title() -> String {
            
            switch self {
            case .activity: return NSLocalizedString("ACTIVITY", comment: "Activity section title")
            case .medication: return NSLocalizedString("MEDICATION", comment: "Medication section title")
            }
        }
    }
    
    enum FTMedicationActivityTitle: Int {
        case type = 0, date, distance, duration, elevation, source
        static let count = 6
        
        func title() -> String {
            
            switch self {
            case .type: return NSLocalizedString("Type:", comment: "Activity type title")
            case .date: return NSLocalizedString("Date:", comment: "Activity date title")
            case .distance: return NSLocalizedString("Distance:", comment: "Activity distance title")
            case .duration: return NSLocalizedString("Duration:", comment: "Activity duration title")
            case .elevation: return NSLocalizedString("Elevation:", comment: "Activity elevation title")
            case .source: return NSLocalizedString("Source:", comment: "Activity source title")
            }
        }
        
        func value(activity: Activity) -> String {
            
            switch self {
            case .type:
                if activity.type != nil {
                    if let type = ActivityType(rawValue: activity.type!) {
                        return type.localizedName(false)
                    }
                }
            case .date:
                if activity.startDate != nil {
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .MediumStyle
                    formatter.timeStyle = .MediumStyle
                    
                    return formatter.stringFromDate(activity.startDate!)
                }
                
            case .distance: return activity.verboseDistance()
                
            case .elevation: return activity.verboseElevation()
            case .duration: return activity.verboseDuration(true)
            case .source:
                if activity.source != nil {
                    return activity.source!
                }
            }
            
            return ""
        }
        
        func valueIcon(activity: Activity!) -> UIImage? {
            
            switch self {
            case .type:
                if activity.type != nil {
                    if let type = ActivityType(rawValue: activity.type!) {
                        return type.icon()
                    }
                }
            default: return nil
            }
            
            return nil
        }
    }
    
    enum FTMedicationTitle: Int {
        case type = 0, dosage, mood
        static let count = 3
        
        func title() -> String {
        
            switch self {
            case .type: return NSLocalizedString("Medication type:", comment: "Medication type title")
            case .dosage: return NSLocalizedString("Dosage: ", comment: "Dosage title")
            case .mood: return NSLocalizedString("Mood:", comment: "Mood title")
            }
        }
        
        func value(medication: Medication) -> String {
            
            switch self {
            case .type:
                if medication.type != nil {
                    if let type = MedicationType(rawValue: medication.type!) {
                        return type.localizedString()
                    }
                }
            case .dosage:
                if medication.dosage != nil {
                    return medication.dosage!.stringValue
                }
            case .mood:
                if medication.mood != nil {
                    if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                        return mood.localizedString()
                    }
                }
            }
            
            return ""
        }
        
        func valueIcon(medication: Medication) -> UIImage? {
            
            switch self {
            case .mood:
                if medication.mood != nil {
                    return UIImage(named: "icon_mood-\(medication.mood!.integerValue)")
                }
            default: return nil
            }
            
            return nil
        }
    }
    
    private let activityEditSegueId = "editActivity"
    private let medicationEditSegueId = "editMedication"
    
    private let firstHeaderPadding: CGFloat = 15.0
    private let headerheight: CGFloat = 30.0
    
    // MARK: - Controller LifeCycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        detailsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customization
    
    private func addEditButton() {
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "btn_edit"), style: .Plain, target: self, action: #selector(self.editTouched(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupTableView() {
        
        detailsTableView.backgroundColor = UIColor.clearColor()
        detailsTableView.tableHeaderView = UIView()
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Medication", comment: "Medication detail navigation title")
        
        addEditButton()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        setupTableView()
        
        deleteButton.ft_setupButton(UIColor.ftMidGray(), title: NSLocalizedString("DELETE MEDICATION & ACTIVITY", comment: "Delete medication button title"))
    }
    
    // MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return medication.activity != nil ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if medication.activity == nil {
            return FTMedicationTitle.count
        }
        else if let sectionType = FTMedicationDetailSection(rawValue: section) {
            switch sectionType {
            case .activity: return FTMedicationActivityTitle.count
            case .medication: return FTMedicationTitle.count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! FTMedicationDetailCell
        
        var title = ""
        var value = ""
        var icon: UIImage?
        
        if medication.activity == nil {
            
            if let medicationTitle = FTMedicationTitle(rawValue: indexPath.row) {
                title = medicationTitle.title()
                value = medicationTitle.value(medication)
                icon = medicationTitle.valueIcon(medication)
            }
        }
        else {
            
            if let sectionType =  FTMedicationDetailSection(rawValue: indexPath.section) {
                switch sectionType {
                case .activity:
                    if let acivityTitle = FTMedicationActivityTitle(rawValue: indexPath.row) {
                        title = acivityTitle.title()
                        value = acivityTitle.value(medication.activity!)
                        icon = acivityTitle.valueIcon(medication.activity!)
                    }
                case .medication:
                    if let medicationTitle = FTMedicationTitle(rawValue: indexPath.row) {
                        title = medicationTitle.title()
                        value = medicationTitle.value(medication)
                        icon = medicationTitle.valueIcon(medication)
                    }
                }
            }
        }
        
        cell.configureCell(title, value: value, icon: icon)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let holder = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: headerheight))
        holder.backgroundColor = UIColor.clearColor()
        holder.autoresizingMask = .FlexibleWidth
        
        let label = UILabel(frame: CGRect(x: 17, y: 0, width: holder.frame.size.width - 34, height: holder.frame.size.height - firstHeaderPadding))
        label.backgroundColor = UIColor.clearColor()
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        label.font = UIFont.defaultFont(.Bold, size: 15.0)
        label.textColor = UIColor.whiteColor()
        
        holder.addSubview(label)
        
        if let sectionType = FTMedicationDetailSection(rawValue: section) {
            label.text = sectionType.title()
        }
        
        return holder
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return headerheight
    }
    
    // MARK: - Actions
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteTouched(sender: AnyObject) {
        
        let alert = UIAlertController(title: NSLocalizedString("Delete Medication", comment: "Delete medication alert title"), message: NSLocalizedString("Are you sure?", comment: "Delete medication confirmation alert message"), preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete title"), style: .Destructive, handler: { (action) in
            self.deleteMedication(self.medication)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func editTouched(sender: AnyObject) {
        
        if medication.activity != nil && medication.activity!.source != nil {
            performSegueWithIdentifier(medicationEditSegueId, sender: self)
        }
        else {
            performSegueWithIdentifier(activityEditSegueId, sender: self)
        }
    }
    
    // MARK: - Data integration
    
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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(FTMedicationDeletedNotificationName, object: self)
                    
                    hud.hideAnimated(true)
                    
                    if success {
                        
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    else {
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to delete medication:(", comment: "Error message when failed to delete medication"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == activityEditSegueId {
            
            let target = segue.destinationViewController as! FTManualActivityTrackViewController
            
            target.activity = medication.activity
            target.medication = medication
        }
        else if segue.identifier == medicationEditSegueId {
            
            let target = segue.destinationViewController as! FTLogActivityViewController
            
            target.activity = medication.activity
            target.medication = medication
        }
    }

}

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

    var medication: Medication!
    
    private let cellId = "medicationCell"
    
    enum FTMedicationDetailSection: Int {
        case activity = 0, medication
    }
    
    enum FTMedicationActivityTitle: Int {
        case type = 0, date, distance, duration, elevation, source
        static let count = 6
    }
    
    enum FTMedicationTitle: Int {
        case type = 0, dosage, mood
        static let count = 3
    }
    
    private let activityEditSegueId = "editActivity"
    private let medicationEditSegueId = "editMedication"
    
    // MARK: - Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        if medication.activity == nil {
            title = medicationPropertyTitle(indexPath.row)
            value = medicationPropertyValue(medication, index: indexPath.row)
        }
        else {
            if let sectionType =  FTMedicationDetailSection(rawValue: indexPath.section) {
                switch sectionType {
                case .activity:
                    title = activityPropertyTitle(indexPath.row)
                    value = activityPropertyValue(medication.activity!, index: indexPath.row)
                case .medication:
                    title = medicationPropertyTitle(indexPath.row)
                    value = medicationPropertyValue(medication, index: indexPath.row)
                }
            }
        }
        
        cell.configureCell(title, value: value)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionType = FTMedicationDetailSection(rawValue: section) {
            switch sectionType {
            case .activity: return NSLocalizedString("Activity", comment: "Activity section title")
            case .medication: return NSLocalizedString("Medication", comment: "Medication section title")
            }
        }
        
        return nil
    }
    
    // MARK: - Actions
    
    @IBAction func deleteTouched(sender: AnyObject) {
        
        let alert = UIAlertController(title: NSLocalizedString("Delete Medication", comment: "Delete medication alert title"), message: NSLocalizedString("Are you sure?", comment: "Delete medication confirmation alert message"), preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete title"), style: .Destructive, handler: { (action) in
            self.deleteMedication(self.medication)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func editTouched(sender: AnyObject) {
        
        if medication.activity != nil && medication.activity!.source != nil {
            performSegueWithIdentifier(medicationEditSegueId, sender: self)
        }
        else {
            performSegueWithIdentifier(activityEditSegueId, sender: self)
        }
    }
    
    // MARK: - Data integration
    
    private func medicationPropertyValue(medication: Medication, index: Int) -> String {
        
        if let titleType = FTMedicationTitle(rawValue: index) {
            switch titleType {
            case .type:
                if medication.type != nil {
                    if let type = MedicationType(rawValue: medication.type!) {
                        return "\(type)"
                    }
                }
            case .dosage:
                if medication.dosage != nil {
                    return medication.dosage!.stringValue
                }
            case .mood:
                if medication.mood != nil {
                    if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                        return "\(mood)"
                    }
                }
            }
        }
        
        return ""
    }
    
    private func medicationPropertyTitle(index: Int) -> String {
        
        if let titleType = FTMedicationTitle(rawValue: index) {
            switch titleType {
            case .type: return NSLocalizedString("Medication type:", comment: "Medication type title")
            case .dosage: return NSLocalizedString("Dosage: ", comment: "Dosage title")
            case .mood: return NSLocalizedString("Mood:", comment: "Mood title")
            }
        }
        
        return ""
    }
    
    private func activityPropertyValue(activity: Activity, index: Int) -> String {
        
        if let activityTitle = FTMedicationActivityTitle(rawValue: index) {
            switch activityTitle {
            case .type:
                if activity.type != nil {
                    if let type = ActivityType(rawValue: activity.type!) {
                        return "\(type)"
                    }
                }
            case .date:
                if activity.startDate != nil {
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .ShortStyle
                    formatter.timeStyle = .ShortStyle
                    
                    return formatter.stringFromDate(activity.startDate!)
                }
                
            case .distance:
                if activity.distance != nil {
                    return "\(activity.distance!.doubleValue / 1000) km"
                }
                
            case .elevation:
                if activity.elevationGain != nil {
                    return activity.elevationGain!.stringValue
                }
            case .duration:
                if activity.elapsedTime != nil {
                    let hours = (Double)((Int)(activity.elapsedTime!.doubleValue / 3600.0))
                    let mins = (Double)((Int)((activity.elapsedTime!.doubleValue - (hours * 3600.0)) / 60))
                    let secs = (Int)(activity.elapsedTime!.doubleValue - (hours * 3600.0) - (mins * 60.0))
                    return "\(hours):\(mins):\(secs)"
                }
            case .source:
                if activity.source != nil {
                    return activity.source!
                }
            }
        }
        
        return ""
    }
    
    private func activityPropertyTitle(index: Int) -> String {
        
        if let activityTitle = FTMedicationActivityTitle(rawValue: index) {
            switch activityTitle {
            case .type: return NSLocalizedString("Activity type:", comment: "Activity type title")
            case .date: return NSLocalizedString("Date:", comment: "Date title")
            case .distance: return NSLocalizedString("Distance:", comment: "Distance title")
            case .elevation: return NSLocalizedString("Total elevation gain:", comment: "Elevation title")
            case .duration: return NSLocalizedString("Duration:", comment: "Duration title")
            case .source: return NSLocalizedString("Source:", comment: "Source title")
            }
        }
        
        return ""
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

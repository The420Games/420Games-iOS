//
//  FTLogActivityViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTLogActivityViewController: UIViewController {
    
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var dosageTextView: UITextField!
    @IBOutlet weak var moodButton: UIButton!
    
    var activity: Activity?
    let medication = Medication()
    
    private let typePlaceholderLabel = NSLocalizedString("Select medication type", comment: "Medication type placeholder")
    private let moodPLaceHolderLabel = NSLocalizedString("Select mood", comment: "Mood placeholder")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Log activity", comment: "Log activity title")
        
        setupUI()
        
        loadActivityDetails()
        
        medication.activity = activity
        
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        activityLabel.text = NSLocalizedString("Activity", comment: "Activity details placeholder")
        
        dosageTextView.placeholder = NSLocalizedString("Enter dosage", comment: "Dosage placeholder")
        
        moodButton.setTitle(moodPLaceHolderLabel, forState: .Normal)
        
        typeButton.setTitle(typePlaceholderLabel, forState: .Normal)
        
        dosageTextView.text = nil
    }
    
    private func loadActivityDetails() {
        
        if activity != nil {
            
            var title = ""
            if activity!.name != nil {
                title += activity!.name!
            }
            
            if activity!.type != nil {
                
                if !title.isEmpty {
                    title += " "
                }
                title += "(" + activity!.type! + ")"
            }
            
            if activity!.startDate != nil {
                
                if !title.isEmpty {
                    title += " "
                }
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .ShortStyle
                formatter.timeStyle = .ShortStyle
                
                title += "at " + formatter.stringFromDate(activity!.startDate!)
            }
            
            if activity!.distance != nil {
                
                if !title.isEmpty {
                    title += " "
                }
                title += "Distance: \(activity!.distance!.doubleValue / 1000) km"
            }
            
            if activity!.elapsedTime != nil {
                if !title.isEmpty {
                    title += " "
                }
                let hours = (Double)((Int)(activity!.elapsedTime!.doubleValue / 3600.0))
                let mins = (Double)((Int)((activity!.elapsedTime!.doubleValue - (hours * 3600.0)) / 60))
                let secs = (Int)(activity!.elapsedTime!.doubleValue - (hours * 3600.0) - (mins * 60.0))
                title += " duration: \(hours):\(mins):\(secs) "
            }
            
            activityLabel.text = title
        }
    }
    
    // MARK: - Actions

    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select type", comment: "Medication type picker title"), message: nil, preferredStyle: .ActionSheet)
        for type in MedicationType.allValues {
            picker.addAction(UIAlertAction(title: "\(type)", style: .Default, handler: { (action) in
                self.medication.type = type.rawValue
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func moodButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select mood", comment: "Mood index picker title"), message: nil, preferredStyle: .ActionSheet)
        for mood in MedicationMoodIndex.allValues {
            picker.addAction(UIAlertAction(title: "\(mood)", style: .Default, handler: { (action) in
                self.medication.mood = NSNumber(integer: mood.rawValue)
                self.moodButton.setTitle("\(mood)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        submitMedication()
    }
    
    // MARK: - Data integration
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if medication.activity == nil {
            errors.append(NSLocalizedString("Missing activity", comment: "Error when activity not set"))
        }
        
        if medication.type == nil {
            errors.append(NSLocalizedString("Missing type", comment: "Error when type not set"))
        }
        
        if medication.mood == nil {
            errors.append(NSLocalizedString("Missing mood", comment: "Error when mood not set"))
        }
        
        if dosageTextView.text == nil || dosageTextView.text!.isEmpty || NSString(string: dosageTextView.text!).doubleValue <= 0 {
            errors.append(NSLocalizedString("Missing dosage", comment: "Error when dosage not set"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    private func submitMedication() {
        
        if validData() {
            medication.dosage = NSNumber(double: NSString(string: dosageTextView.text!).doubleValue)
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.label.text = NSLocalizedString("Submitting Medication", comment: "HUD title when submitting Medication")
            hud.mode = .Indeterminate
            
            medication.saveInBackgroundWithBlock({ (success, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    hud.hideAnimated(true)
                    
                    if success {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    else {
                        print("Error saving Medication: \(error)")
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to save Activity:(", comment: "Error message when failed to save Medication"), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                })
                
            })
        }
    }
}

//
//  FTLogActivityViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD
import ActionSheetPicker_3_0

class FTLogActivityViewController: UIViewController {
    
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var dosageTextField: FTTextField!
    
    @IBOutlet weak var moodButton: UIButton!
    
    var activity: Activity?
    var medication: Medication!
    
    private let typePlaceholderLabel = NSLocalizedString("SET MEDICATION TYPE", comment: "Medication type placeholder")
    private let moodPLaceHolderLabel = NSLocalizedString("SET MOOD", comment: "Mood placeholder")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Log activity", comment: "Log activity title")
        
        setupUI()
        
        if medication == nil {

            medication = Medication()
            medication.activity = activity
        }
        else {
            activity = medication.activity
        }
        
        loadActivityDetails()
        
        loadMedicationDetails()
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Add medication", comment: "Add medication navigation title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        addSaveButton()
        
        activityLabel.textColor = UIColor.whiteColor()
        activityLabel.font = UIFont.defaultFont(.Medium, size: 15.0)
        activityLabel.text = NSLocalizedString("Activity", comment: "Activity details placeholder")
        
        dosageTextField.ft_setup()
        dosageTextField.ft_setPlaceholder(NSLocalizedString("ENTER DOSAGE", comment: "Dosage placeholder"))
        
        moodButton.ft_setupButton(UIColor.ftLimeGreen(), title: moodPLaceHolderLabel)

        typeButton.ft_setupButton(UIColor.ftLimeGreen(), title: typePlaceholderLabel)
        
        dosageTextField.text = nil
    }
    
    private func addSaveButton() {
    
        let item = UIBarButtonItem(image: UIImage(named: "btn_save"), style: .Done, target: self, action: #selector(self.saveButtonPressed(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    private func loadActivityDetails() {
        
        if activity != nil {
            
            if activity!.type != nil {
                
                if let type = ActivityType(rawValue: activity!.type!) {
                    activityImageView.image = type.icon()
                }
            }
            
            var title = ""
            
            if activity!.name != nil {
                title += activity!.name!
            }
            else if activity!.type != nil {
                
                if let type = ActivityType(rawValue: activity!.type!) {
                    
                    title += type.localizedName(true).capitalizingFirstLetter()
                }
            }
            
            title += " " + activity!.verboseDistance()
            
            title += "\n"
            
            title += activity!.verboseDuration(true)
            
            if activity!.startDate != nil {
            
                let formatter = NSDateFormatter()
                formatter.dateStyle = .ShortStyle
                formatter.timeStyle = .ShortStyle
                
                title += " " + NSLocalizedString("at", comment: "Time prefix") + " "
                
                title += formatter.stringFromDate(activity!.startDate!)
            }
            
            activityLabel.text = title
        }
    }
    
    private func loadMedicationDetails() {
        
        if medication.type != nil {
            if let type = MedicationType(rawValue: medication.type!) {
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }
        }
        
        if medication.dosage != nil {
            dosageTextField.text = medication.dosage!.stringValue
        }
        
        if medication.mood != nil {
            if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                self.moodButton.setTitle("\(mood)", forState: .Normal)
            }
        }
    }
    
    private func endEditing() {
        
        dosageTextField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func textfieldDidExit(sender: FTTextField) {
        
        sender.resignFirstResponder()
    }
    
    func saveButtonPressed(sender: AnyObject) {
    
        endEditing()
        submitMedication()
    }
    
    func backButtonPressed(sender: AnyObject) {
        
        endEditing()
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        endEditing()
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for type in MedicationType.allValues {
            rows.append(type.localizedString().capitalizingFirstLetter())
            if medication.type != nil && medication.type! == type.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select type", comment: "Medication type picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            self.medication.type = MedicationType.allValues[index].rawValue
            self.typeButton.setTitle(value as? String, forState: .Normal)
            }, cancelBlock: { (picker) in
                //
            }, origin: sender)
        
        picker.showActionSheetPicker()
    }
    
    @IBAction func moodButtonPressed(sender: AnyObject) {
        
        endEditing()
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for type in MedicationMoodIndex.allValues {
            rows.append(type.localizedString().capitalizingFirstLetter())
            if medication.mood != nil && medication.mood!.integerValue == type.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select mood", comment: "Mood index picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            self.medication.mood = MedicationMoodIndex.allValues[index].rawValue
            self.moodButton.setTitle(value as? String, forState: .Normal)
            }, cancelBlock: { (picker) in
                //
            }, origin: sender)
        
        picker.showActionSheetPicker()
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
        
        if dosageTextField.text == nil || dosageTextField.text!.isEmpty || NSString(string: dosageTextField.text!).doubleValue <= 0 {
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
            medication.dosage = NSNumber(double: NSString(string: dosageTextField.text!).doubleValue)
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.label.text = NSLocalizedString("Submitting Medication", comment: "HUD title when submitting Medication")
            hud.mode = .Indeterminate
            
            medication.saveInBackgroundWithBlock({ (success, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    hud.hideAnimated(true)
                    
                    if success {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(FTMedicationSavedNotificationName, object: self, userInfo: ["medicaton": self.medication])
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

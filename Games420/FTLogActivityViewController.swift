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
    
    fileprivate let typePlaceholderLabel = NSLocalizedString("SET MEDICATION TYPE", comment: "Medication type placeholder")
    fileprivate let moodPLaceHolderLabel = NSLocalizedString("SET MOOD", comment: "Mood placeholder")
    
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
        
        FTAnalytics.trackEvent(.CreateMedication, data: nil)
    }
    
    // MARK: - UI Customization
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Add medication", comment: "Add medication navigation title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        addSaveButton()
        
        activityLabel.textColor = UIColor.white
        activityLabel.font = UIFont.defaultFont(.medium, size: 15.0)
        activityLabel.text = NSLocalizedString("Activity", comment: "Activity details placeholder")
        
        dosageTextField.ft_setup()
        dosageTextField.ft_setPlaceholder(NSLocalizedString("ENTER DOSAGE", comment: "Dosage placeholder"))
        
        moodButton.ft_setupButton(UIColor.ftLimeGreen(), title: moodPLaceHolderLabel)

        typeButton.ft_setupButton(UIColor.ftLimeGreen(), title: typePlaceholderLabel)
        
        dosageTextField.text = nil
    }
    
    fileprivate func addSaveButton() {
    
        let item = UIBarButtonItem(image: UIImage(named: "btn_save"), style: .done, target: self, action: #selector(self.saveButtonPressed(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    fileprivate func loadActivityDetails() {
        
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
            
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                title += " " + NSLocalizedString("at", comment: "Time prefix") + " "
                
                title += formatter.string(from: activity!.startDate! as Date)
            }
            
            activityLabel.text = title
        }
    }
    
    fileprivate func loadMedicationDetails() {
        
        if medication.type != nil {
            if let type = MedicationType(rawValue: medication.type!) {
                self.typeButton.setTitle("\(type)", for: UIControlState())
            }
        }
        
        if medication.dosage != nil {
            dosageTextField.text = medication.dosage!.stringValue
        }
        
        if medication.mood != nil {
            if let mood = MedicationMoodIndex(rawValue: medication.mood!.intValue) {
                self.moodButton.setTitle("\(mood)", for: UIControlState())
            }
        }
    }
    
    fileprivate func endEditing() {
        
        dosageTextField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func textfieldDidExit(_ sender: FTTextField) {
        
        sender.resignFirstResponder()
    }
    
    func saveButtonPressed(_ sender: AnyObject) {
    
        endEditing()
        submitMedication()
    }
    
    func backButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func typeButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for type in MedicationType.allValues {
            rows.append(type.localizedString().capitalizingFirstLetter() as AnyObject)
            if medication.type != nil && medication.type! == type.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select type", comment: "Medication type picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            let type = MedicationType.allValues[index]
            self.medication.type = type.rawValue
            self.typeButton.setTitle(value as? String, for: UIControlState())
            
            FTAnalytics.trackEvent(.SelectMedicationType, data: ["type": "\(type)" as AnyObject])
            
            }, cancel: { (picker) in
                //
            }, origin: sender)
        
        picker?.show()
    }
    
    @IBAction func moodButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for type in MedicationMoodIndex.allValues {
            rows.append(type.localizedString().capitalizingFirstLetter() as AnyObject)
            if medication.mood != nil && medication.mood!.intValue == type.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select mood", comment: "Mood index picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            let mood = MedicationMoodIndex.allValues[index]
            self.medication.mood = mood.rawValue as NSNumber?
            self.moodButton.setTitle(value as? String, for: UIControlState())
            
            FTAnalytics.trackEvent(.SelectMood, data: ["mood": "\(mood)" as AnyObject])
            
            }, cancel: { (picker) in
                //
            }, origin: sender)
        
        picker?.show()
    }
    
    // MARK: - Data integration
    
    fileprivate func validData() -> Bool {
        
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
            
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: errors.joined(separator: "\n"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    fileprivate func submitMedication() {
        
        if validData() {
            medication.dosage = NSNumber(value: NSString(string: dosageTextField.text!).doubleValue as Double)
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("Submitting Medication", comment: "HUD title when submitting Medication")
            hud.mode = .indeterminate
            
            medication.saveInBackgroundWithBlock({ (success, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    hud.hide(animated: true)
                    
                    if success {
                        
                        FTAnalytics.trackEvent(.SubmitMedication, data: nil)
                        
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: FTMedicationSavedNotificationName), object: self, userInfo: ["medicaton": self.medication])
                    }
                    else {
                        print("Error saving Medication: \(error)")
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to save Activity:(", comment: "Error message when failed to save Medication"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                })
                
            })
        }
    }
}

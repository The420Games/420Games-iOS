//
//  FTManualActivityTrackViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 28..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class FTManualActivityTrackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var elevationTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var dateButton: UIButton!
    
    private let typeButtonTitle = NSLocalizedString("Set type", comment: "Select activity type title")
    private let dateButtonTitle = NSLocalizedString("Set date", comment: "Select activity date title")
    
    private let medicationSegueId = "logActivity"
    
    private lazy var dateFormatter: NSDateFormatter = {
       
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }()
    
    var activity: Activity!
    var medication: Medication?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if activity == nil {
            activity = Activity()
        }
        
        addNextButton()
        
        setupUI()
        
        loadActivityDetails()
    }
    
    private func setupUI() {
        
        typeButton.setTitle(typeButtonTitle, forState: .Normal)
        distanceTextField.text = nil
        elevationTextField.text = nil
        durationTextField.text = nil
        dateButton.setTitle(dateButtonTitle, forState: .Normal)
    }
    
    private func loadActivityDetails() {
        
        if activity.type != nil {
            if let type = ActivityType(rawValue: activity.type!) {
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }
        }
        
        if activity.distance != nil {
            distanceTextField.text = activity.distance!.stringValue
        }
        
        if activity.elevationGain != nil {
            elevationTextField.text = activity.elevationGain!.stringValue
        }
        
        if activity.elapsedTime != nil {
            durationTextField.text = activity.elapsedTime!.stringValue
        }
        
        if activity.startDate != nil {
            dateButton.setTitle(dateFormatter.stringFromDate(activity.startDate!), forState: .Normal)
        }
        
        nameTextField.text = activity.name
    }
    
    private func addNextButton() {
        
        let barItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next button title"), style: .Plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        navigationItem.rightBarButtonItem = barItem
    }
    
    // MARK: - Actions
    
    func nextButtonPressed(sender: AnyObject) {
        
        if validData() {
            performSegueWithIdentifier(medicationSegueId, sender: self)
        }
    }
    
    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select Activity type", comment: "Activity type picker title"), message: nil, preferredStyle: .ActionSheet)
        for type in ActivityType.allValues {
            picker.addAction(UIAlertAction(title: "\(type)", style: .Default, handler: { (action) in
                self.activity.type = type.rawValue
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func dateButtonTouched(sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: NSLocalizedString("Select activity date", comment: "Activity date picker tite"), datePickerMode: UIDatePickerMode.DateAndTime, selectedDate: self.activity.startDate != nil ? self.activity.startDate : NSDate(), doneBlock: {
            picker, value, index in
            
            if let date = value as? NSDate {
                
                self.activity.startDate = date
                self.dateButton.setTitle(self.dateFormatter.stringFromDate(date), forState: .Normal)
            }
            
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.view)
        
        datePicker.minimumDate = NSDate(timeInterval: -1 * 365 * 24 * 60 * 60, sinceDate: NSDate())
        datePicker.maximumDate = NSDate()
        
        datePicker.showActionSheetPicker()
    }
    
    // MARK: - Data integration
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if activity.distance?.doubleValue <= 0 {
            errors.append(NSLocalizedString("Please set distance!", comment: "Missing distance error message"))
        }
        
        if activity.type == nil || activity.type!.isEmpty {
            errors.append(NSLocalizedString("Please set activity type", comment: "Missing activity type error message"))
        }
        
        if activity.elapsedTime?.doubleValue <= 0 {
            errors.append(NSLocalizedString("Please set activity duration", comment: "Missing duration error message"))
        }
        
        if activity.startDate == nil {
            errors.append(NSLocalizedString("Please set date", comment: "Missing date error message"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == medicationSegueId {
            (segue.destinationViewController as! FTLogActivityViewController).activity = self.activity
            if medication != nil {
                (segue.destinationViewController as! FTLogActivityViewController).medication = self.medication!
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let text = textField.text {
            
            let string = NSString(string: text)
            let number = NSNumber(double: string.doubleValue)
            
            if textField == distanceTextField {
                activity.distance = number
            }
            else if textField == durationTextField {
                activity.elapsedTime = number
            }
            else if textField == elevationTextField {
                activity.elevationGain = number
            }
            else if textField == nameTextField {
                activity.name = textField.text
            }
        }
    }
}

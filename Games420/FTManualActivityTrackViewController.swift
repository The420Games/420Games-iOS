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
    
    @IBOutlet weak var distanceTextField: FTTextField!
    @IBOutlet weak var elevationTextField: FTTextField!
    @IBOutlet weak var nameTextField: FTTextField!
    
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    
    private let typeButtonTitle = NSLocalizedString("SET ACTIVITY TYPE", comment: "Select activity type title")
    private let dateButtonTitle = NSLocalizedString("SET ACTIVITY DATE", comment: "Select activity date title")
    private let durationButtonTitle = NSLocalizedString("SET ACTIVITY DURATION", comment: "Select activity duration title")
    
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
        
        setupUI()
        
        loadActivityDetails()
    }
    
    private func setupUI() {
        
        navigationItem.title = NSLocalizedString("Add activity", comment: "Manual activity add title")
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        addNextButton()
        
        distanceTextField.ft_setup()
        distanceTextField.ft_setPlaceholder(NSLocalizedString("DISTANCE", comment: "Distance placeholder") + " (" + (Activity.isMetricSystem() ? NSLocalizedString("km", comment: "kilometer"): NSLocalizedString("miles", comment: "Miles")) + ")")
        distanceTextField.text = nil
        
        elevationTextField.ft_setup()
        elevationTextField.ft_setPlaceholder(NSLocalizedString("ELEVATION", comment: "Elevation placeholder") + " (" + (Activity.isMetricSystem() ? NSLocalizedString("m", comment: "meter"): NSLocalizedString("feet", comment: "Feet")) + ")")
        elevationTextField.text = nil
        
        nameTextField.ft_setup()
        nameTextField.ft_setPlaceholder(NSLocalizedString("EXERCISE NAME", comment: "Exercise name placeholder"))
        nameTextField.text = nil
        
        let btnColor = UIColor.ftLimeGreen()
        typeButton.ft_setupButton(btnColor, title: typeButtonTitle)
        durationButton.ft_setupButton(btnColor, title: durationButtonTitle)
        dateButton.ft_setupButton(btnColor, title: dateButtonTitle)
    }
    
    private func loadActivityDetails() {
        
        if activity.type != nil {
            if let type = ActivityType(rawValue: activity.type!) {
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }
        }
        
        if activity.distance != nil {
            let dist = Activity.isMetricSystem() ? String(activity.distance!.doubleValue / 1000) : String(activity.distance!.doubleValue / Activity.metersInMile)
            distanceTextField.text = dist
        }
        
        if activity.elevationGain != nil {
            let elev = Activity.isMetricSystem() ? activity.elevationGain!.stringValue : String(activity.elevationGain!.doubleValue / Activity.metersInFoot)
            elevationTextField.text = elev
        }
        
        if activity.elapsedTime != nil {
            durationButton.setTitle(activity.verboseDuration(false), forState: .Normal)
        }
        
        if activity.startDate != nil {
            dateButton.setTitle(dateFormatter.stringFromDate(activity.startDate!), forState: .Normal)
        }
        
        nameTextField.text = activity.name
    }
    
    private func addNextButton() {
        
        let item = UIBarButtonItem(image: UIImage(named: "btn_next"), style: .Plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    // MARK: - Actions
    
    func nextButtonPressed(sender: AnyObject) {
        
        self.editing = false
        if validData() {
            performSegueWithIdentifier(medicationSegueId, sender: self)
        }
    }
    
    @IBAction func textFieldExit(sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        var types = [AnyObject]()
        var typeIndex = 0
        var i = 0
        for type in ActivityType.allValues {
            types.append(type.localizedName(false).capitalizingFirstLetter())
            if type.rawValue == activity.type {
                typeIndex = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select Activity type", comment: "Activity type picker title"), rows: types, initialSelection: typeIndex, doneBlock: { (picker, index, value) in
            
            let type = ActivityType.allValues[index]
            self.activity.type = type.rawValue
            self.typeButton.setTitle(value as? String, forState: .Normal)
            
            }, cancelBlock: { (picker) in
                //
            }, origin: sender)
        
        picker.showActionSheetPicker()
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
    
    @IBAction func durationButtonTouched(sender: AnyObject) {
        
        var hour: Double = -1
        var min: Double = -1
        var sec: Int = -1
        if let time = activity.elapsedTime {
            hour = (Double)((Int)(time.doubleValue / 3600.0))
            min = (Double)((Int)((time.doubleValue - (hour * 3600.0)) / 60))
            sec = (Int)(time.doubleValue - (hour * 3600.0) - (min * 60.0))
        }
        
        var hours = [AnyObject]()
        var hourIndex = 0
        hours.append(NSLocalizedString("Hours", comment: "Hours placeholder"))
        for h in 0 ... 24 {
            hours.append("\(h)")
            let hD = Double(h)
            if hD == hour {
                hourIndex = h + 1
            }
        }
        
        var minutes = [AnyObject]()
        var minIndex = 0
        minutes.append(NSLocalizedString("Mins", comment: "Minutes placeholder"))
        
        var seconds = [AnyObject]()
        var secIndex = 0
        seconds.append(NSLocalizedString("Secs", comment: "Seconds placeholder"))
        
        for m in 0 ... 59 {
            let mD = Double(m)
            minutes.append("\(m)")
            seconds.append("\(m)")
            
            if mD == min {
                minIndex = m + 1
            }
            if m == sec {
                secIndex = m + 1
            }
        }
        let rows = [hours, minutes, seconds]
        
        _ = ActionSheetMultipleStringPicker.showPickerWithTitle(NSLocalizedString("Set duration", comment: "Duration picker title"), rows: rows, initialSelection: [hourIndex, minIndex, secIndex], doneBlock: { (picker, indexes, values) in
            
            var duration = 0
            
            if let hour = values[0] as? NSString {
                duration += hour.integerValue * 3600
            }
            
            if let min = values[1] as? NSString {
                duration += min.integerValue * 60
            }
            
            if let sec = values[2] as? NSString {
                duration += sec.integerValue
            }
            
            self.activity.elapsedTime = duration
            if duration > 0 {
                self.durationButton.setTitle(self.activity.verboseDuration(false), forState: .Normal)
            }
            else {
                self.durationButton.setTitle(self.durationButtonTitle, forState: .Normal)
            }
            
            }, cancelBlock: { (picker) in
                //
            }, origin: sender)
        
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
                activity.distance = Activity.isMetricSystem() ? number.doubleValue * 1000 : number.doubleValue * Activity.metersInMile
            }
            else if textField == elevationTextField {
                activity.elevationGain = Activity.isMetricSystem() ? number : number.doubleValue * Activity.metersInFoot
            }
            else if textField == nameTextField {
                activity.name = textField.text
            }
        }
    }
}

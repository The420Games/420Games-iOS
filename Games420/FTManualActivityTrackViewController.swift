//
//  FTManualActivityTrackViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 28..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class FTManualActivityTrackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var distanceTextField: FTTextField!
    @IBOutlet weak var elevationTextField: FTTextField!
    @IBOutlet weak var nameTextField: FTTextField!
    
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    
    fileprivate let typeButtonTitle = NSLocalizedString("SET ACTIVITY TYPE", comment: "Select activity type title")
    fileprivate let dateButtonTitle = NSLocalizedString("SET ACTIVITY DATE", comment: "Select activity date title")
    fileprivate let durationButtonTitle = NSLocalizedString("SET ACTIVITY DURATION", comment: "Select activity duration title")
    
    fileprivate let medicationSegueId = "logActivity"
    
    fileprivate lazy var dateFormatter: DateFormatter = {
       
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
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
        
        FTAnalytics.trackEvent(.ManualActivity, data: nil)
    }
    
    fileprivate func setupUI() {
        
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
    
    fileprivate func loadActivityDetails() {
        
        if activity.type != nil {
            if let type = ActivityType(rawValue: activity.type!) {
                self.typeButton.setTitle("\(type)", for: UIControlState())
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
            durationButton.setTitle(activity.verboseDuration(false), for: UIControlState())
        }
        
        if activity.startDate != nil {
            dateButton.setTitle(dateFormatter.string(from: activity.startDate! as Date), for: UIControlState())
        }
        
        nameTextField.text = activity.name
    }
    
    fileprivate func addNextButton() {
        
        let item = UIBarButtonItem(image: UIImage(named: "btn_next"), style: .plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    fileprivate func endEditing() {
        
        distanceTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        elevationTextField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    func nextButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        
        if validData() {
            performSegue(withIdentifier: medicationSegueId, sender: self)
        }
    }
    
    @IBAction func textFieldExit(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    func backButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func typeButtonPressed(_ sender: AnyObject) {
        
        endEditing()
        
        var types = [AnyObject]()
        var typeIndex = 0
        var i = 0
        for type in ActivityType.allValues {
            types.append(type.localizedName(false).capitalizingFirstLetter() as AnyObject)
            if type.rawValue == activity.type {
                typeIndex = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select Activity type", comment: "Activity type picker title"), rows: types, initialSelection: typeIndex, doneBlock: { (picker, index, value) in
            
            let type = ActivityType.allValues[index]
            self.activity.type = type.rawValue
            self.typeButton.setTitle(value as? String, for: UIControlState())
            
            FTAnalytics.trackEvent(.SelectActivityType, data: ["type": "\(type)" as AnyObject])
            
            }, cancel: { (picker) in
                //
            }, origin: sender)
        
        picker?.show()
    }
    
    @IBAction func dateButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        
        let datePicker = ActionSheetDatePicker(title: NSLocalizedString("Select activity date", comment: "Activity date picker tite"), datePickerMode: UIDatePickerMode.dateAndTime, selectedDate: self.activity.startDate != nil ? self.activity.startDate : Date(), doneBlock: {
            picker, value, index in
            
            if let date = value as? Date {
                
                self.activity.startDate = date
                self.dateButton.setTitle(self.dateFormatter.string(from: date), for: UIControlState())
            }
            
            }, cancel: { ActionStringCancelBlock in return }, origin: self.view)
        
        datePicker?.minimumDate = Date(timeInterval: -1 * 365 * 24 * 60 * 60, since: Date())
        datePicker?.maximumDate = Date()
        
        datePicker?.show()
    }
    
    @IBAction func durationButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        
        var hour: Double = 0
        var min: Double = 0
        var sec: Int = 0
        if let time = activity.elapsedTime {
            hour = (Double)((Int)(time.doubleValue / 3600.0))
            min = (Double)((Int)((time.doubleValue - (hour * 3600.0)) / 60))
            sec = (Int)(time.doubleValue - (hour * 3600.0) - (min * 60.0))
        }
        
        var hours = [AnyObject]()
        var hourIndex = 0
        hours.append(NSLocalizedString("Hours", comment: "Hours placeholder") as AnyObject)
        for h in 0 ... 24 {
            hours.append("\(h)" as AnyObject)
            let hD = Double(h)
            if hD == hour {
                hourIndex = h + 1
            }
        }
        
        var minutes = [AnyObject]()
        var minIndex = 0
        minutes.append(NSLocalizedString("Mins", comment: "Minutes placeholder") as AnyObject)
        
        var seconds = [AnyObject]()
        var secIndex = 0
        seconds.append(NSLocalizedString("Secs", comment: "Seconds placeholder") as AnyObject)
        
        for m in 0 ... 59 {
            let mD = Double(m)
            minutes.append("\(m)" as AnyObject)
            seconds.append("\(m)" as AnyObject)
            
            if mD == min {
                minIndex = m + 1
            }
            if m == sec {
                secIndex = m + 1
            }
        }
        let rows = [hours, minutes, seconds]
        
        _ = ActionSheetMultipleStringPicker.show(withTitle: NSLocalizedString("Set duration", comment: "Duration picker title"), rows: rows, initialSelection: [hourIndex, minIndex, secIndex], doneBlock: { (picker, indexes, values) in
            
            var duration = 0
            
            if let valuesArray = values as? [NSString] {
            
                if valuesArray.count > 0 {
                    let hour = valuesArray[0]
                    duration += hour.integerValue * 3600
                }
                
                if valuesArray.count > 1 {
                    let min = valuesArray[1]
                    duration += min.integerValue * 60
                }
                
                if valuesArray.count > 2 {
                    let sec = valuesArray[2]
                    duration += sec.integerValue
                }
            }
            
            self.activity.elapsedTime = duration as NSNumber?
            if duration > 0 {
                self.durationButton.setTitle(self.activity.verboseDuration(false), for: UIControlState())
            }
            else {
                self.durationButton.setTitle(self.durationButtonTitle, for: UIControlState())
            }
            
        }, cancel: { (picker) in
            //
        }, origin: sender)
    }
    
    // MARK: - Data integration
    
    fileprivate func validData() -> Bool {
        
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
            
            let alert = UIAlertController(title: nil, message: errors.joined(separator: "\n"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == medicationSegueId {
            (segue.destination as! FTLogActivityViewController).activity = self.activity
            if medication != nil {
                (segue.destination as! FTLogActivityViewController).medication = self.medication!
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let text = textField.text {
            
            let string = NSString(string: text)
            let number = NSNumber(value: string.doubleValue as Double)
            
            if textField == distanceTextField {
                activity.distance = (Activity.isMetricSystem() ? number.doubleValue * 1000 : number.doubleValue * Activity.metersInMile) as NSNumber?
            }
            else if textField == elevationTextField {
                activity.elevationGain = Activity.isMetricSystem() ? number : number.doubleValue * Activity.metersInFoot as NSNumber
            }
            else if textField == nameTextField {
                activity.name = textField.text
            }
        }
    }
}

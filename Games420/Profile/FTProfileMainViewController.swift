//
//  FTProfileMainViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 04..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD
import ActionSheetPicker_3_0

class FTProfileMainViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var editHolderView: UIView!
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    private var _edit = false
    var edit : Bool {
        get {
            return self._edit
        }
        set {
            self._edit = newValue
            if self.view != nil || self.isViewLoaded() {
                
                self.editHolderView.hidden = !newValue
                
                if let rightItem = self.navigationItem.rightBarButtonItem {
                    rightItem.title = edit ? saveTitle : editTitle
                }
                
                if let leftItem = self.navigationItem.leftBarButtonItem {
                    leftItem.title = edit ? cancelTitle : backTitle
                }
            }
        }
    }
    
    private var birthDate: NSDate?
    private var gender: String?
    private var profilePicture: String?
    
    private let editTitle = NSLocalizedString("Edit", comment: "Edit button title")
    private let saveTitle = NSLocalizedString("Save", comment: "Save button title")
    private let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
    private let backTitle = NSLocalizedString("Back", comment: "Back button title")
    private let bDayTitle = NSLocalizedString("Set birth date", comment: "Set birth date button title")
    private let genderTitle = NSLocalizedString("Set gender", comment: "Set gender button title")

    override func viewDidLoad() {
        
        super.viewDidLoad()

        editHolderView.hidden = !edit
        
        addRightButtonItem()
        
        addLeftButtonItem()
        
        populateData()
        
        fetchAthlete()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  - UI Customization
    
    private func addRightButtonItem() {
        
        let barButtonItem = UIBarButtonItem(title: edit ? saveTitle : editTitle, style: .Plain, target: self, action: #selector(self.rightBarButtonItemPressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func addLeftButtonItem() {
        
        let barButtonItem = UIBarButtonItem(title: edit ? cancelTitle : backTitle, style: .Plain, target: self, action: #selector(self.leftBarButtonItemPressed(_:)))
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    // MARK: - Actions
    
    func rightBarButtonItemPressed(sender: AnyObject) {
        
        if !edit {
            edit  = true
        }
        else if validData() {
            updateAthlete()
        }
    }
    
    func leftBarButtonItemPressed(sender: AnyObject) {
        
        if edit {
            edit = false
            populateData()
        }
        else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func genderButtonTouched(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select Gender", comment: "gender picker title"), message: nil, preferredStyle: .ActionSheet)
        for gender in GenderType.allValues {
            picker.addAction(UIAlertAction(title: "\(gender)", style: .Default, handler: { (action) in
                self.gender = gender.rawValue
                self.genderButton.setTitle("\(gender)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func birthdateButtonTouched(sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: NSLocalizedString("Select birth date", comment: "Birth date picker tite"), datePickerMode: UIDatePickerMode.Date, selectedDate: birthDate != nil ? birthDate : NSDate(), doneBlock: {
            picker, value, index in
            
            if let date = value as? NSDate {
            
                self.birthDate = date
                self.updateBirthDay(date)
            }

            }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.view)

        datePicker.minimumDate = NSDate(timeInterval: -120 * 365 * 24 * 60 * 60, sinceDate: NSDate())
        datePicker.maximumDate = NSDate()
        
        datePicker.showActionSheetPicker()
    }
    
    // MARK: - Populate data
    
    private func updateNameLabel(firstName: String?, lastName: String?) {
        
        nameLabel.text = "\(lastName != nil && !lastName!.isEmpty ? lastName! : "")\(lastName != nil && !lastName!.isEmpty ? ", " : "")\(firstName != nil ? firstName! : "")"
    }
    
    private func updateLocalityLabel(country: String?, state: String?, city: String?) {
        
        var title = ""
        
        if country != nil && !country!.isEmpty {
            title += country!
        }
        
        if state != nil && !state!.isEmpty {
            if !title.isEmpty {
                title += ", "
            }
            
            title += state!
        }
        
        if city != nil && !city!.isEmpty {
            if !title.isEmpty {
                title += ", "
            }
            
            title += city!
        }
        
        localityLabel.text = title
    }
    
    private func updateBirthDay(date: NSDate?) {
        
        if let bday = date {
        
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .NoStyle
            
            let bdString = formatter.stringFromDate(bday)
            birthdayLabel.text = bdString
            birthdayButton.setTitle(bdString, forState: .Normal)
            self.birthDate = bday
            
        }
        else {
            birthdayLabel.text = ""
            birthdayButton.setTitle(bDayTitle, forState: .Normal)
        }
        
    }

    private func populateData() {

        if let athlete = FTDataManager.sharedInstance.currentUser?.athlete {

            updateNameLabel(athlete.firstName, lastName: athlete.lastName)
            
            firstnameTextField.text = athlete.firstName
            lastnameTextField.text = athlete.lastName
            
            updateLocalityLabel(athlete.country, state: athlete.state, city: athlete.locality)
            
            countryTextField.text = athlete.country
            stateTextField.text = athlete.state
            cityTextField.text = athlete.locality
            
            updateBirthDay(athlete.birthDay)
            
            self.gender = athlete.gender
            let gender = athlete.localizedGender()
            genderLabel.text = gender
            if !gender.isEmpty {
                genderButton.setTitle(gender, forState: .Normal)
            }
            else {
                genderButton.setTitle(genderTitle, forState: .Normal)
            }
            
            bioLabel.text = athlete.bio
            bioTextView.text = athlete.bio
            
            profilePicture = athlete.profileImage
            if let url = FTDataManager.sharedInstance.imageUrlForProperty(profilePicture, path: Athlete.profileImagePath) {
                profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "default_photo"), optionsInfo: .None, progressBlock: nil, completionHandler: nil)
            }
            else {
                profileImageView.image = UIImage(named: "default_photo")
            }
            
        }
        else {
            
            nameLabel.text = ""
            firstnameTextField.text = nil
            lastnameTextField.text = nil
            
            localityLabel.text = ""
            countryTextField.text = nil
            stateTextField.text = nil
            cityTextField.text = nil
            
            birthdayLabel.text = ""
            birthdayButton.setTitle(bDayTitle, forState: .Normal)
            
            genderLabel.text = ""
            genderButton.setTitle(genderTitle, forState: .Normal)
            
            profileImageView.image = UIImage(named: "default_photo")
        }
        
    }
    
    // MARK: - Data integration
    
    private func fetchAthlete() {
        
        if let athleteId = FTDataManager.sharedInstance.currentUser?.athlete?.objectId {
            
            Athlete.findFirstObject("objectId = '\(athleteId)'", completion: { (object, error) in
                
                if error == nil && object != nil {
                    FTDataManager.sharedInstance.currentUser?.athlete = object as? Athlete
                    self.populateData()
                }
            })
            
        }
    }
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if firstnameTextField.text == nil || firstnameTextField.text!.isEmpty {
            errors.append(NSLocalizedString("Please provide your first name!", comment: "Error label when first name missing on profile screen"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    private func updateAthlete() {
        
        let athlete = Athlete()
        if FTDataManager.sharedInstance.currentUser!.athlete != nil {
            athlete.objectId = FTDataManager.sharedInstance.currentUser!.athlete!.objectId
        }
        
        athlete.firstName = firstnameTextField.text
        athlete.lastName = lastnameTextField.text
        athlete.country = countryTextField.text
        athlete.state = stateTextField.text
        athlete.locality = cityTextField.text
        athlete.gender = self.gender
        athlete.birthDay = birthDate
        athlete.bio = bioTextView.text
        athlete.profileImage = profilePicture
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .Indeterminate
        
        athlete.saveInBackground { (object, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
            
                if object != nil && error == nil {
                    
                    let needsUpdateUser = FTDataManager.sharedInstance.currentUser!.athlete == nil
                    
                    FTDataManager.sharedInstance.currentUser!.athlete = object as? Athlete
                    
                    if needsUpdateUser {
                        
                        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        hud.label.text = NSLocalizedString("Updating account", comment: "HUD title when updating user account")
                        hud.mode = .Indeterminate
                        
                        FTDataManager.sharedInstance.currentUser!.saveInBackground({ (object, error) in
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                hud.hideAnimated(true)
                                
                                if object != nil && error == nil {
                                    self.edit = false
                                    self.populateData()
                                }
                                else {
                                    print("Error saving User: \(error)")
                                    
                                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to update account:(", comment: "Error message when failed to save User"), preferredStyle: .Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            })
                        })
                    }
                    else {
                        self.edit = false
                        self.populateData()
                    }
                }
                else {
                    print("Error saving Athlete: \(error)")
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to update profile:(", comment: "Error message when failed to save Athlete"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

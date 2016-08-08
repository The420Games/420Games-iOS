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

class FTProfileMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    private var profilePicture: UIImage?
    
    private let editTitle = NSLocalizedString("Edit", comment: "Edit button title")
    private let saveTitle = NSLocalizedString("Save", comment: "Save button title")
    private let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
    private let backTitle = NSLocalizedString("Back", comment: "Back button title")
    private let bDayTitle = NSLocalizedString("Set birth date", comment: "Set birth date button title")
    private let genderTitle = NSLocalizedString("Set gender", comment: "Set gender button title")
    
    private var waitingForStravaAuthentication = false

    override func viewDidLoad() {
        
        super.viewDidLoad()

        editHolderView.hidden = !edit
        
        addRightButtonItem()
        
        addLeftButtonItem()
        
        populateData(FTDataManager.sharedInstance.currentUser?.athlete)
        
        fetchAthlete()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        if waitingForStravaAuthentication {
            manageForStravaNotification(false)
        }
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
            profilePicture = nil
            birthDate = nil
            gender = nil
            populateData(FTDataManager.sharedInstance.currentUser?.athlete)
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
    
    @IBAction func photoTapped(sender: AnyObject) {
        
        if edit {
            startPhotoSelection()
        }
    }
    
    @IBAction func stravaButtonTouched(sender: AnyObject) {
        
        completeWithStrava()
    }
    
    @IBAction func facebookButtonTouched(sender: AnyObject) {
        
        completeWithFacebook()
    }
    
    // MARK: - Photo
    
    private func startPhotoSelection() {
        
        // If camrea and photo library are available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // Both available, ask user
            queryPhotoSource()
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // Just camera available
            takePhoto()
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // Just library available
            queryPhotoSource()
        }
    }
    
    private func queryPhotoSource() {
        
        let alert = UIAlertController(title: NSLocalizedString("Select source", comment: "Select photo source title"), message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take new photo", comment: "Take new photo title"), style: .Default, handler: { (action) in
            self.takePhoto()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera roll", comment: "Choose photo from library title"), style: .Default, handler: { (action) in
            self.selectPhotoFromCameraRoll()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func selectPhotoFromCameraRoll() {
        
        getPhoto(.SavedPhotosAlbum)
    }
    
    private func takePhoto() {
        getPhoto(.Camera)
    }
    
    // Start image picker or camera
    private func getPhoto(sourceType: UIImagePickerControllerSourceType)
    {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Photo selection callback
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Hide picker
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage;
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        
        picker.dismissViewControllerAnimated(true) { () -> Void in

            if image != nil {
            
                self.profilePicture = image!
                self.profileImageView.image = image!
            }
        }
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

    private func populateData(currentAthlete: Athlete?) {

        if let athlete = currentAthlete {

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
            
            if profilePicture != nil {
                profileImageView.image = profilePicture
            }
            else if let url = FTDataManager.sharedInstance.imageUrlForProperty(athlete.profileImage, path: Athlete.profileImagePath) {
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
                    self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
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
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .Indeterminate
        
        let group = dispatch_group_create();
        
        if profilePicture != nil {
            
            dispatch_group_enter(group)
            FTDataManager.sharedInstance.uploadImage(profilePicture!, path: Athlete.profileImagePath, completion: { (fileName, error) in
         
                if error == nil {
                    athlete.profileImage = fileName
                }
                else {
                    self.profilePicture = nil
                }
                
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            
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
                                        self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
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
                            self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
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
    }
    
    // MARK: - Strava integration
    
    private func completeWithStrava() {
        
        if !FTStravaManager.sharedInstance.isAuthorized {
            
            waitingForStravaAuthentication = true
            manageForStravaNotification(true)
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.label.text = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            hud.mode = .Indeterminate
            
            FTStravaManager.sharedInstance.updateAthleteWhenAuhtorized = false
            FTStravaManager.sharedInstance.authorize("games420://games420")
        }
        else {
            
            fetchAthleteFromStrava()
        }
    }
    
    private func fetchAthleteFromStrava() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .Indeterminate
        
        FTStravaManager.sharedInstance.fetchAthlete(nil, completion: { (athleteData, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
            
                if athleteData != nil {
                    
                    let athlete = Athlete.dataFromJsonObject(athleteData!) as! Athlete
                    athlete.source = FTStravaManager.sharedInstance.ftStravaSourceId
                
                    let group = dispatch_group_create();
                    
                    dispatch_group_enter(group)
                    
                    let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
                    hud.mode = .Indeterminate
                    
                    FTStravaManager.sharedInstance.fetchAthleteProfileImage(athleteData!, completion: { (image, error) in
            
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            hud.hideAnimated(true)
                            
                            self.profilePicture = image
                        })
                        
                        dispatch_group_leave(group)
                    })
                    
                    dispatch_group_notify(group, dispatch_get_main_queue()) {
            
                        self.populateData(athlete)
                    }
                }
                else {
                    
                    print("Error fetching Athlete: \(error)")
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to fetch profile:(", comment: "Error message when failed to fetch Athlete from Strava"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        })
    }
    
    // MARK: Notifications
    
    private func manageForStravaNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stravaNotificationReceived(_:)), name: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: nil)
        }
    }
    
    func stravaNotificationReceived(notification: NSNotification) {
        
        if waitingForStravaAuthentication {
            
            manageForStravaNotification(false)
            
            waitingForStravaAuthentication = false
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if let success = notification.userInfo?["success"] as? Bool {
                if success {
                    fetchAthleteFromStrava()
                }
            }
        }
    }
    
    // MARK: - Facebook integration
    
    private func completeWithFacebook() {
        
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

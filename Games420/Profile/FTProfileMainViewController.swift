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
import FBSDKCoreKit

class FTProfileMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var localityTitleLabel: UILabel!
    @IBOutlet weak var genderTitleLabel: UILabel!
    @IBOutlet weak var birthdateTitleLabel: UILabel!
    @IBOutlet weak var bioTitleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet var horizontalLines: [UIView]!
    
    @IBOutlet weak var editHolderView: UIView!
    
    @IBOutlet weak var firstnameTextField: FTTextField!
    @IBOutlet weak var lastnameTextField: FTTextField!
    @IBOutlet weak var countryTextField: FTTextField!
    @IBOutlet weak var stateTextField: FTTextField!
    @IBOutlet weak var cityTextField: FTTextField!
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var stravaButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    
    private var _edit = false
    var edit : Bool {
        get {
            return self._edit
        }
        set {
            self._edit = newValue
            if self.view != nil || self.isViewLoaded() {
                
                self.editHolderView.hidden = !newValue
                self.passwordButton.hidden = newValue
                
                if let rightItem = self.navigationItem.rightBarButtonItem {
                    rightItem.image = UIImage(named: edit ? "btn_save" : "btn_edit")
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
    private var stravaAuthenticationHUD: MBProgressHUD?
    
    //Facebook keys
    private let kFacebookKeyId = "id"
    private let kFacebookKeyEmail = "email"
    private let kFacebookKeyFirstName = "first_name"
    private let kFacebookKeyLastName = "last_name"
    private let kFacebookKeyGender = "gender"
    private let kFacebookKeyBirthday = "birthday"
    private let kFacebookKeyLocation = "location"
    private let kFacebookKeyLocationName = "name"
    
    private let cropSegueId = "cropPhoto"

    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
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
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        setupProfilePicture()
    }
    
    // MARK:  - UI Customization
    
    private func setupProfilePicture() {
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
        profileImageView.layer.borderColor = UIColor.ftLimeGreen().CGColor
        profileImageView.layer.borderWidth = profileImageView.bounds.size.width / 20
    }
    
    private func setupTitleLabels() {
        
        let titleFont = UIFont.defaultFont(.Light, size: 13.5)
        let titleColor = UIColor.whiteColor()
        
        nameTitleLabel.font = titleFont
        nameTitleLabel.textColor = titleColor
        nameTitleLabel.text = NSLocalizedString("NAME", comment: "Name title label")
        
        localityTitleLabel.font = titleFont
        localityTitleLabel.textColor = titleColor
        localityTitleLabel.text = NSLocalizedString("LOCATION", comment: "Location title label")
        
        genderTitleLabel.font = titleFont
        genderTitleLabel.textColor = titleColor
        genderTitleLabel.text = NSLocalizedString("GENDER", comment: "Gender title label")
        
        birthdateTitleLabel.font = titleFont
        birthdateTitleLabel.textColor = titleColor
        birthdateTitleLabel.text = NSLocalizedString("BIRTHDAY", comment: "Birthday title label")
        
        bioTitleLabel.font = titleFont
        bioTitleLabel.textColor = titleColor
        bioTitleLabel.text = NSLocalizedString("BIO", comment: "Bio title label")
    }
    
    private func setupDataLabels() {
        
        let font = UIFont.defaultFont(.Bold, size: 14.5)
        let color = UIColor.whiteColor()
        
        nameLabel.font = font
        nameLabel.textColor = color
        
        localityLabel.font = font
        localityLabel.textColor = color
        
        genderLabel.font = font
        genderLabel.textColor = color
        
        birthdayLabel.font = font
        birthdayLabel.textColor = color
        
        bioLabel.font = font
        bioLabel.textColor = color
    }
    
    private func setupButons() {
        
        let bColor = UIColor.ftLimeGreen()
        
        genderButton.ft_setupButton(bColor, title: genderTitle)
        birthdayButton.ft_setupButton(bColor, title: bDayTitle)
        passwordButton.ft_setupButton(bColor, title: NSLocalizedString("CHANGE PASSWORD", comment: "Change password title"))
        
        facebookButton.ft_setupButton(UIColor.ftFacebookBlue(), title: NSLocalizedString("COMPLETE WITH FACEBOOK", comment: "Complete with facebook title"))
        
        stravaButton.ft_setupButton(UIColor.ftStravaOrange(), title: NSLocalizedString("COMPLETE WITH STRAVA", comment: "Complete with Strava title"))
    }
    
    private func setupTextFields() {
        
        firstnameTextField.ft_setup()
        firstnameTextField.ft_setPlaceholder(NSLocalizedString("FIRST NAME", comment: "First name placeholder"))
        
        lastnameTextField.ft_setup()
        lastnameTextField.ft_setPlaceholder(NSLocalizedString("LAST NAME", comment: "Last name placeholder"))
        
        countryTextField.ft_setup()
        countryTextField.ft_setPlaceholder(NSLocalizedString("COUNTRY", comment: "Country placeholder"))
        
        stateTextField.ft_setup()
        stateTextField.ft_setPlaceholder(NSLocalizedString("ST", comment: "State placeholder"))
        
        cityTextField.ft_setup()
        cityTextField.ft_setPlaceholder(NSLocalizedString("CITY", comment: "City placeholder"))
    }
    
    private func setupBioTextView() {
        
        bioTextView.backgroundColor = UIColor.clearColor()
        bioTextView.clipsToBounds = true
        bioTextView.layer.borderWidth = 1.0
        bioTextView.layer.borderColor = UIColor.ftMidGray().CGColor
        bioTextView.layer.cornerRadius = 5.0
        
        bioTextView.tintColor = UIColor.whiteColor()
        bioTextView.textColor = UIColor.whiteColor()
        bioTextView.font = UIFont.defaultFont(.Light, size: 13.0)
        
        bioTextView.keyboardAppearance = .Dark
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        editHolderView.backgroundColor = UIColor.ftMainBackgroundColor()
        
        editHolderView.hidden = !edit
        
        addRightButtonItem()
        
        addLeftButtonItem()
        
        for line in horizontalLines {
            line.backgroundColor = UIColor.ftMidGray()
        }
        
        setupTitleLabels()
        
        setupDataLabels()
        
        setupButons()
        
        setupTextFields()
        
        setupBioTextView()
    }
    
    private func addRightButtonItem() {
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: edit ? "btn_save" : "btn_edit"), style: .Plain, target: self, action: #selector(self.rightBarButtonItemPressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func addLeftButtonItem() {
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: .Plain, target: self, action: #selector(self.leftBarButtonItemPressed(_:)))
        
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
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for g in GenderType.allValues {
            rows.append(g.localizedString().capitalizingFirstLetter())
            if gender == g.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select Gender", comment: "gender picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            self.gender = value as? String
            self.genderButton.setTitle(GenderType.allValues[index].localizedString().capitalizingFirstLetter(), forState: .Normal)
            
            }, cancelBlock: { (picker) in
                
            }, origin: sender)

        picker.showActionSheetPicker()
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
            
                self.performSegueWithIdentifier(self.cropSegueId, sender: image!)
            }
        }
    }
    
    // MARK: - Populate data
    
    
    
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

            nameLabel.text = athlete.fullName()
            
            firstnameTextField.text = athlete.firstName
            lastnameTextField.text = athlete.lastName
            
            localityLabel.text = athlete.fullLocality()
            
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
            
            stravaAuthenticationHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            stravaAuthenticationHUD!.label.text = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            stravaAuthenticationHUD!.mode = .Indeterminate
            
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
                    hud.label.text = NSLocalizedString("Fetching profile picture", comment: "HUD title when updating profile picture from Strava")
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
            
            if stravaAuthenticationHUD != nil {
                stravaAuthenticationHUD!.hideAnimated(true)
                stravaAuthenticationHUD = nil
            }
            
            if let success = notification.userInfo?["success"] as? Bool {
                if success {
                    fetchAthleteFromStrava()
                }
            }
        }
    }
    
    // MARK: - Facebook integration
    
    private func completeWithFacebook() {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .Indeterminate
        
        let athletete = Athlete()
        
        //Request Facebook for the data
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, link, first_name, last_name, email, birthday, location, hometown, picture, gender"]).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection?, fbUser:AnyObject?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                hud.hideAnimated(true)
            
                if error == nil {
                    
                    if let dict = fbUser as? NSDictionary {
                        
                        if let firstName = dict.objectForKey(self.kFacebookKeyFirstName) as? String {
                            athletete.firstName = firstName
                        }
                        
                        if let lastName = dict.objectForKey(self.kFacebookKeyLastName) as? String {
                            athletete.lastName = lastName
                        }
                        
                        if let gender = dict.objectForKey(self.kFacebookKeyGender) as? String {
                            if gender == "male" {
                                athletete.gender = "M"
                            }
                            else if gender == "female" {
                                athletete.gender = "F"
                            }
                        }
                        
                        if let bDayStr = dict.objectForKey(self.kFacebookKeyBirthday) as? String {
                            athletete.birthDay = self.convertBirthdayToDate(bDayStr)
                        }
                        
                        if let location = dict.objectForKey(self.kFacebookKeyLocation), nameLocation = location.objectForKey(self.kFacebookKeyLocationName) as? String {
                            athletete.locality = nameLocation
                        }
                        
                        var pictureUrl: NSURL?
                        if let picture = dict.objectForKey("picture") as? NSDictionary {
                            if let data = picture.objectForKey("data") as? NSDictionary {
                                if let url = data.objectForKey("url") as? String {
                                    pictureUrl = NSURL(string: url)
                                }
                            }
                        }
                        
                        if pictureUrl == nil {
                            self.populateData(athletete)
                        }
                        else {
                            
                            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            hud.label.text = NSLocalizedString("Fetching profile picture", comment: "HUD title when updating profile picture from Facebook")
                            hud.mode = .Indeterminate
                            
                            KingfisherManager.sharedManager.downloader.downloadImageWithURL(pictureUrl!, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    hud.hideAnimated(true)
                                    
                                    self.profilePicture = image
                                    self.populateData(athletete)
                                })
                            })
                        }
                    }
                }
            })
        })
    }
    
    func convertBirthdayToDate(birthday:String) -> NSDate? {
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        if let date = dateFormatter.dateFromString(birthday) {
            return date
        } else {
            return nil
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == cropSegueId {
            let target = segue.destinationViewController as! FTPhotoCropViewController
            target.originalPhoto = sender as! UIImage
            target.completionBlock = {(croppedPhoto: UIImage) -> () in
                
                self.profilePicture = croppedPhoto
                self.profileImageView.image = croppedPhoto
            }
        }
    }

}

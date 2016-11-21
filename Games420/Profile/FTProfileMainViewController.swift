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

let FTProfileUpdatedNotificationName = "FTProfileUpdatedNotification"

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
    
    fileprivate var _edit = false
    var edit : Bool {
        get {
            return self._edit
        }
        set {
            self._edit = newValue
            if self.view != nil || self.isViewLoaded {
                
                self.editHolderView.isHidden = !newValue
                self.passwordButton.isHidden = newValue
                
                if let rightItem = self.navigationItem.rightBarButtonItem {
                    rightItem.image = UIImage(named: edit ? "btn_save" : "btn_edit")
                }
            }
        }
    }
    
    fileprivate var birthDate: Date?
    fileprivate var gender: String?
    fileprivate var profilePicture: UIImage?
    
    fileprivate let editTitle = NSLocalizedString("Edit", comment: "Edit button title")
    fileprivate let saveTitle = NSLocalizedString("Save", comment: "Save button title")
    fileprivate let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
    fileprivate let backTitle = NSLocalizedString("Back", comment: "Back button title")
    fileprivate let bDayTitle = NSLocalizedString("Set birth date", comment: "Set birth date button title")
    fileprivate let genderTitle = NSLocalizedString("Set gender", comment: "Set gender button title")
    
    fileprivate var waitingForStravaAuthentication = false
    fileprivate var stravaAuthenticationHUD: MBProgressHUD?
    
    //Facebook keys
    fileprivate let kFacebookKeyId = "id"
    fileprivate let kFacebookKeyEmail = "email"
    fileprivate let kFacebookKeyFirstName = "first_name"
    fileprivate let kFacebookKeyLastName = "last_name"
    fileprivate let kFacebookKeyGender = "gender"
    fileprivate let kFacebookKeyBirthday = "birthday"
    fileprivate let kFacebookKeyLocation = "location"
    fileprivate let kFacebookKeyLocationName = "name"
    
    fileprivate let cropSegueId = "cropPhoto"

    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        populateData(FTDataManager.sharedInstance.currentUser?.athlete)
        
        fetchAthlete()
        
        FTAnalytics.trackEvent(.Profile, data: nil)
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
    
    fileprivate func setupProfilePicture() {
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
        profileImageView.layer.borderColor = UIColor.ftLimeGreen().cgColor
        profileImageView.layer.borderWidth = profileImageView.bounds.size.width / 20
    }
    
    fileprivate func setupTitleLabels() {
        
        let titleFont = UIFont.defaultFont(.light, size: 13.5)
        let titleColor = UIColor.white
        
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
    
    fileprivate func setupDataLabels() {
        
        let font = UIFont.defaultFont(.bold, size: 14.5)
        let color = UIColor.white
        
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
    
    fileprivate func setupButons() {
        
        let bColor = UIColor.ftLimeGreen()
        
        genderButton.ft_setupButton(bColor, title: genderTitle)
        birthdayButton.ft_setupButton(bColor, title: bDayTitle)
        passwordButton.ft_setupButton(bColor, title: NSLocalizedString("CHANGE PASSWORD", comment: "Change password title"))
        
        facebookButton.ft_setupButton(UIColor.ftFacebookBlue(), title: NSLocalizedString("COMPLETE WITH FACEBOOK", comment: "Complete with facebook title"))
        
        stravaButton.ft_setupButton(UIColor.ftStravaOrange(), title: NSLocalizedString("COMPLETE WITH STRAVA", comment: "Complete with Strava title"))
    }
    
    fileprivate func setupTextFields() {
        
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
    
    fileprivate func setupBioTextView() {
        
        bioTextView.backgroundColor = UIColor.clear
        bioTextView.clipsToBounds = true
        bioTextView.layer.borderWidth = 1.0
        bioTextView.layer.borderColor = UIColor.ftMidGray().cgColor
        bioTextView.layer.cornerRadius = 5.0
        
        bioTextView.tintColor = UIColor.white
        bioTextView.textColor = UIColor.white
        bioTextView.font = UIFont.defaultFont(.light, size: 13.0)
        
        bioTextView.keyboardAppearance = .dark
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        editHolderView.backgroundColor = UIColor.ftMainBackgroundColor()
        
        editHolderView.isHidden = !edit
        
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
    
    fileprivate func addRightButtonItem() {
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: edit ? "btn_save" : "btn_edit"), style: .plain, target: self, action: #selector(self.rightBarButtonItemPressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    fileprivate func addLeftButtonItem() {
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: .plain, target: self, action: #selector(self.leftBarButtonItemPressed(_:)))
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    // MARK: - Actions
    
    fileprivate func endEditing() {
        
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        
        countryTextField.resignFirstResponder()
        stateTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        
        bioTextView.resignFirstResponder()
    }
    
    func rightBarButtonItemPressed(_ sender: AnyObject) {
        
        if !edit {
            
            edit  = true
            FTAnalytics.trackEvent(.EditProfile, data: nil)
            
        }
        else {
            
            endEditing()
            
            if validData() {
                updateAthlete()
            }
        }
    }
    
    func leftBarButtonItemPressed(_ sender: AnyObject) {
        
        if edit {
            
            endEditing()
            edit = false
            profilePicture = nil
            birthDate = nil
            gender = nil
            populateData(FTDataManager.sharedInstance.currentUser?.athlete)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func genderButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        
        var rows = [AnyObject]()
        var index = 0
        var i = 0
        for g in GenderType.allValues {
            rows.append(g.localizedString().capitalizingFirstLetter() as AnyObject)
            if gender == g.rawValue {
                index = i
            }
            i += 1
        }
        
        let picker = ActionSheetStringPicker(title: NSLocalizedString("Select Gender", comment: "gender picker title"), rows: rows, initialSelection: index, doneBlock: { (picker, index, value) in
            
            let gender = GenderType.allValues[index]
            self.gender = gender.rawValue
            self.genderButton.setTitle(gender.localizedString().capitalizingFirstLetter(), for: UIControlState())
            
            }, cancel: { (picker) in
                
            }, origin: sender)

        picker?.show()
    }
    
    @IBAction func birthdateButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        
        let datePicker = ActionSheetDatePicker(title: NSLocalizedString("Select birth date", comment: "Birth date picker tite"), datePickerMode: UIDatePickerMode.date, selectedDate: birthDate != nil ? birthDate : Date(), doneBlock: {
            picker, value, index in
            
            if let date = value as? Date {
            
                self.birthDate = date
                self.updateBirthDay(date)
            }

            }, cancel: { ActionStringCancelBlock in return }, origin: self.view)

        datePicker?.minimumDate = Date(timeInterval: -120 * 365 * 24 * 60 * 60, since: Date())
        datePicker?.maximumDate = Date()
        
        datePicker?.show()
    }
    
    @IBAction func photoTapped(_ sender: AnyObject) {
        
        if edit {
            
            endEditing()
            startPhotoSelection()
        }
    }
    
    @IBAction func stravaButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        completeWithStrava()
    }
    
    @IBAction func facebookButtonTouched(_ sender: AnyObject) {
        
        endEditing()
        completeWithFacebook()
    }
    
    @IBAction func textFieldDidExit(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    // MARK: - Photo
    
    fileprivate func startPhotoSelection() {
        
        // If camrea and photo library are available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            // Both available, ask user
            queryPhotoSource()
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            // Just camera available
            takePhoto()
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            // Just library available
            queryPhotoSource()
        }
    }
    
    fileprivate func queryPhotoSource() {
        
        let alert = UIAlertController(title: NSLocalizedString("Select source", comment: "Select photo source title"), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take new photo", comment: "Take new photo title"), style: .default, handler: { (action) in
            self.takePhoto()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera roll", comment: "Choose photo from library title"), style: .default, handler: { (action) in
            self.selectPhotoFromCameraRoll()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel, handler: nil))
        
        alert.view.tintColor = UIColor.ftLimeGreen()
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func selectPhotoFromCameraRoll() {
        
        getPhoto(.savedPhotosAlbum)
    }
    
    fileprivate func takePhoto() {
        getPhoto(.camera)
    }
    
    // Start image picker or camera
    fileprivate func getPhoto(_ sourceType: UIImagePickerControllerSourceType)
    {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Photo selection callback
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Hide picker
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage;
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        
        picker.dismiss(animated: true) { () -> Void in

            if image != nil {
            
                self.performSegue(withIdentifier: self.cropSegueId, sender: image!)
            }
        }
    }
    
    // MARK: - Populate data
    
    fileprivate func updateBirthDay(_ date: Date?) {
        
        if let bday = date {
        
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            
            let bdString = formatter.string(from: bday)
            birthdayLabel.text = bdString
            birthdayButton.setTitle(bdString, for: UIControlState())
            self.birthDate = bday
            
        }
        else {
            birthdayLabel.text = ""
            birthdayButton.setTitle(bDayTitle, for: UIControlState())
        }
    }

    fileprivate func populateData(_ currentAthlete: Athlete?) {

        if let athlete = currentAthlete {

            nameLabel.text = athlete.fullName()
            
            firstnameTextField.text = athlete.firstName
            lastnameTextField.text = athlete.lastName
            
            localityLabel.text = athlete.fullLocality()
            
            countryTextField.text = athlete.country
            stateTextField.text = athlete.state
            cityTextField.text = athlete.locality
            
            updateBirthDay(athlete.birthDay as Date?)
            
            self.gender = athlete.gender
            let gender = athlete.localizedGender()
            genderLabel.text = gender
            if !gender.isEmpty {
                genderButton.setTitle(gender, for: UIControlState())
            }
            else {
                genderButton.setTitle(genderTitle, for: UIControlState())
            }
            
            bioLabel.text = athlete.bio
            bioTextView.text = athlete.bio
            
            if profilePicture != nil {
                profileImageView.image = profilePicture
            }
            else if let url = FTDataManager.sharedInstance.imageUrlForProperty(athlete.profileImage, path: Athlete.profileImagePath) {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_photo"), options: .none, progressBlock: nil, completionHandler: nil)
            }
            else {
                profileImageView.image = UIImage(named: "default_photo")
            }
            
        }
        else {
            
            nameLabel.text = NSLocalizedString("Name not set", comment: "Name placeholder")
            firstnameTextField.text = nil
            lastnameTextField.text = nil
            
            localityLabel.text = NSLocalizedString("Location not set", comment: "Location placeholder")
            countryTextField.text = nil
            stateTextField.text = nil
            cityTextField.text = nil
            
            birthdayLabel.text = ""
            birthdayButton.setTitle(bDayTitle, for: UIControlState())
            
            genderLabel.text = ""
            genderButton.setTitle(genderTitle, for: UIControlState())
            
            profileImageView.image = UIImage(named: "default_photo")
        }
    }
    
    // MARK: - Data integration
    
    fileprivate func fetchAthlete() {
        
        if let athleteId = FTDataManager.sharedInstance.currentUser?.athlete?.objectId {
            
            Athlete.findFirstObject("objectId = '\(athleteId)'", completion: { (object, error) in
                
                if error == nil && object != nil {
                    FTDataManager.sharedInstance.currentUser?.athlete = object as? Athlete
                    self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
                }
            })
            
        }
    }
    
    fileprivate func validData() -> Bool {
        
        var errors = [String]()
        
        if firstnameTextField.text == nil || firstnameTextField.text!.isEmpty {
            errors.append(NSLocalizedString("Please provide your first name!", comment: "Error label when first name missing on profile screen"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joined(separator: "\n"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    fileprivate func updateAthlete() {
        
        let athlete = Athlete()
        if FTDataManager.sharedInstance.currentUser!.athlete != nil {
            athlete.objectId = FTDataManager.sharedInstance.currentUser!.athlete!.objectId
            athlete.profileImage = FTDataManager.sharedInstance.currentUser!.athlete!.profileImage
        }
        
        athlete.firstName = firstnameTextField.text
        athlete.lastName = lastnameTextField.text
        athlete.country = countryTextField.text
        athlete.state = stateTextField.text
        athlete.locality = cityTextField.text
        athlete.gender = self.gender
        athlete.birthDay = birthDate
        athlete.bio = bioTextView.text
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .indeterminate
        
        let group = DispatchGroup();
        
        if profilePicture != nil {
            
            group.enter()
            FTDataManager.sharedInstance.uploadImage(profilePicture!, path: Athlete.profileImagePath, completion: { (fileName, error) in
         
                if error == nil {
                    athlete.profileImage = fileName
                }
                else {
                    self.profilePicture = nil
                }
                
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            athlete.saveInBackground { (object, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    hud.hide(animated: true)
                    
                    if object != nil && error == nil {
                        
                        FTAnalytics.trackEvent(.SubmitProfile, data: nil)
                        
                        let needsUpdateUser = FTDataManager.sharedInstance.currentUser!.athlete == nil
                        
                        FTDataManager.sharedInstance.currentUser!.athlete = object as? Athlete
                        
                        if needsUpdateUser {
                            
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            hud.label.text = NSLocalizedString("Updating account", comment: "HUD title when updating user account")
                            hud.mode = .indeterminate
                            
                            FTDataManager.sharedInstance.currentUser!.saveInBackground({ (object, error) in
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    hud.hide(animated: true)
                                    
                                    if object != nil && error == nil {
                                        
                                        self.edit = false
                                        self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
                                        
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: FTProfileUpdatedNotificationName), object: self)
                                    }
                                    else {
                                        
                                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to update account:(", comment: "Error message when failed to save User"), preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            })
                        }
                        else {
                            
                            self.edit = false
                            self.populateData(FTDataManager.sharedInstance.currentUser?.athlete)
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: FTProfileUpdatedNotificationName), object: self)
                        }
                    }
                    else {
                        print("Error saving Athlete: \(error)")
                        
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to update profile:(", comment: "Error message when failed to save Athlete"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                })
            }
        }
    }
    
    // MARK: - Strava integration
    
    fileprivate func completeWithStrava() {
        
        if !FTStravaManager.sharedInstance.isAuthorized {
            
            waitingForStravaAuthentication = true
            manageForStravaNotification(true)
            
            stravaAuthenticationHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            stravaAuthenticationHUD!.label.text = NSLocalizedString("Authenticating with Strava", comment: "HUD title when authenticating with Strava")
            stravaAuthenticationHUD!.mode = .indeterminate
            
            FTStravaManager.sharedInstance.updateAthleteWhenAuhtorized = false
            FTStravaManager.sharedInstance.authorize("games420://games420")
        }
        else {
            
            fetchAthleteFromStrava()
        }
    }
    
    fileprivate func fetchAthleteFromStrava() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .indeterminate
        
        FTStravaManager.sharedInstance.fetchAthlete(nil, completion: { (athleteData, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
            
                if athleteData != nil {
                    
                    let athlete = Athlete.dataFromJsonObject(athleteData!) as! Athlete
                    athlete.source = FTStravaManager.sharedInstance.ftStravaSourceId
                
                    let group = DispatchGroup();
                    
                    group.enter()
                    
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.label.text = NSLocalizedString("Fetching profile picture", comment: "HUD title when updating profile picture from Strava")
                    hud.mode = .indeterminate
                    
                    FTStravaManager.sharedInstance.fetchAthleteProfileImage(athleteData!, completion: { (image, error) in
            
                        DispatchQueue.main.async(execute: {
                            
                            hud.hide(animated: true)
                            
                            self.profilePicture = image
                        })
                        
                        group.leave()
                    })
                    
                    group.notify(queue: DispatchQueue.main) {
            
                        self.populateData(athlete)
                    }
                }
                else {
                    
                    print("Error fetching Athlete: \(error)")
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog title"), message: NSLocalizedString("Failed to fetch profile:(", comment: "Error message when failed to fetch Athlete from Strava"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        })
    }
    
    // MARK: Notifications
    
    fileprivate func manageForStravaNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.stravaNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: nil)
        }
    }
    
    func stravaNotificationReceived(_ notification: Notification) {
        
        if waitingForStravaAuthentication {
            
            manageForStravaNotification(false)
            
            waitingForStravaAuthentication = false
            
            if stravaAuthenticationHUD != nil {
                stravaAuthenticationHUD!.hide(animated: true)
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
    
    fileprivate func completeWithFacebook() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Updating profile", comment: "HUD title when updating profile data")
        hud.mode = .indeterminate
        
        let athletete = Athlete()
        
        //Request Facebook for the data
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, link, first_name, last_name, email, birthday, location, hometown, picture, gender"]).start { (connection, fbUser, error) in
            
            DispatchQueue.main.async(execute: {
                
                hud.hide(animated: true)
                
                if error == nil {
                    
                    if let dict = fbUser as? NSDictionary {
                        
                        if let firstName = dict.object(forKey: self.kFacebookKeyFirstName) as? String {
                            athletete.firstName = firstName
                        }
                        
                        if let lastName = dict.object(forKey: self.kFacebookKeyLastName) as? String {
                            athletete.lastName = lastName
                        }
                        
                        if let gender = dict.object(forKey: self.kFacebookKeyGender) as? String {
                            if gender == "male" {
                                athletete.gender = "M"
                            }
                            else if gender == "female" {
                                athletete.gender = "F"
                            }
                        }
                        
                        if let bDayStr = dict.object(forKey: self.kFacebookKeyBirthday) as? String {
                            athletete.birthDay = self.convertBirthdayToDate(bDayStr)
                        }
                        
                        if let location = dict.object(forKey: self.kFacebookKeyLocation), let nameLocation = (location as AnyObject).object(forKey: self.kFacebookKeyLocationName) as? String {
                            athletete.locality = nameLocation
                        }
                        
                        var pictureUrl: URL?
                        if let picture = dict.object(forKey: "picture") as? NSDictionary {
                            if let data = picture.object(forKey: "data") as? NSDictionary {
                                if let url = data.object(forKey: "url") as? String {
                                    pictureUrl = URL(string: url)
                                }
                            }
                        }
                        
                        if pictureUrl == nil {
                            self.populateData(athletete)
                        }
                        else {
                            
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            hud.label.text = NSLocalizedString("Fetching profile picture", comment: "HUD title when updating profile picture from Facebook")
                            hud.mode = .indeterminate
                            
                            KingfisherManager.shared.downloader.downloadImage(with: pictureUrl!, options: .none, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    hud.hide(animated: true)
                                    
                                    self.profilePicture = image
                                    self.populateData(athletete)
                                })
                            })
                        }
                    }
                }
            })
        }
    }
    
    func convertBirthdayToDate(_ birthday:String) -> Date? {
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        if let date = dateFormatter.date(from: birthday) {
            return date
        } else {
            return nil
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == cropSegueId {
            let target = segue.destination as! FTPhotoCropViewController
            target.originalPhoto = sender as! UIImage
            target.completionBlock = {(croppedPhoto: UIImage) -> () in
                
                self.profilePicture = croppedPhoto
                self.profileImageView.image = croppedPhoto
            }
        }
    }

}

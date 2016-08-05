//
//  FTProfileMainViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 04..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

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
            }
        }
    }
    
    private let editTitle = NSLocalizedString("Edit", comment: "Edit button title")
    private let saveTitle = NSLocalizedString("Save", comment: "Save button title")
    private let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
    private let backTitle = NSLocalizedString("Back", comment: "Back button title")

    override func viewDidLoad() {
        
        super.viewDidLoad()

        editHolderView.hidden = !edit
        
        addRightButtonItem()
        
        addLeftButtonItem()
        
        populateData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addRightButtonItem() {
        
        let barButtonItem = UIBarButtonItem(title: edit ? saveTitle : editTitle, style: .Plain, target: self, action: #selector(self.rightBarButtonItemPressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func rightBarButtonItemPressed(sender: AnyObject) {
        
        edit = !edit
        
        if let rightItem = navigationItem.rightBarButtonItem {
            rightItem.title = edit ? saveTitle : editTitle
        }
        
        if let leftItem = navigationItem.leftBarButtonItem {
            leftItem.title = edit ? cancelTitle : backTitle
        }
    }
    
    private func addLeftButtonItem() {
        
        let barButtonItem = UIBarButtonItem(title: edit ? cancelTitle : backTitle, style: .Plain, target: self, action: #selector(self.leftBarButtonItemPressed(_:)))
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func leftBarButtonItemPressed(sender: AnyObject) {
        
        edit = false
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Populate data
    
    private func updateNameLabel(firstName: String?, lastName: String?) {
        
        nameLabel.text = "\(lastName != nil && lastName!.isEmpty ? lastName! : "")\(lastName != nil && lastName!.isEmpty ? ", " : "")\(firstName != nil ? firstName! : "")"
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

    private func populateData() {

        if let athlete = FTDataManager.sharedInstance.currentUser?.athlete {

            updateNameLabel(athlete.firstName, lastName: athlete.lastName)
            
            firstnameTextField.text = athlete.firstName
            lastnameTextField.text = athlete.lastName
            
            updateLocalityLabel(athlete.country, state: athlete.state, city: athlete.locality)
            
            countryTextField.text = athlete.country
            stateTextField.text = athlete.state
            cityTextField.text = athlete.locality
            
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

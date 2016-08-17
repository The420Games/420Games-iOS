//
//  FTAnalytics.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 16..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import Mixpanel

enum FTEvent: String {
    case OnBoarding = "OnBoarding",
    SignUp = "SignUp",
    SignIn = "SignIn",
    PasswordReset = "Password Reset",
    Home = "Home Screen",
    MenuItemSelected = "Menu Item Selected",
    NewActivityFromHome = "New Activity From Home Screen",
    Profile = "Profile Screen",
    EditProfile = "Edit Profile",
    SubmitProfile = "Submit Profile",
    EditProfilePhoto = "Edit Profile Photo",
    Medications = "Medications list",
    MedicationsFilterChange = "Filter medications",
    NewMedication = "New medication",
    DeleteMedication = "Delete Medication",
    EditMedication = "Edit Medication",
    MedicationDetail = "Medication Detail Screen",
    ManualActivity = "Manual Activity Screen",
    SelectActivityType = "Select Activity Type",
    CreateMedication = "Create/Edit Medication Screen",
    SelectMedicationType = "Select Medication Type",
    SelectMood = "Select Mood",
    SubmitMedication = "Submit Medication",
    ActivityPicker = "Activity Picker Screen",
    SelectActivity = "Select Activity",
    Tutorial = "Tutorial Screen",
    SignOut = "Sign Out"
}

class FTAnalytics: NSObject {

    static private let mixpanelKey = "3f0d0950cb84e3458e628521ca4f7fab"
    
    class func initAnalytics() {
        
        _ = Mixpanel.sharedInstanceWithToken(mixpanelKey)
    }
    
    class func trackEvent(event: FTEvent, data: [String: AnyObject]?) {
        
        Mixpanel.sharedInstance().track(event.rawValue, properties: data)
    }
    
    class func identifyUser(userId: String) {
        
        Mixpanel.sharedInstance().identify(userId)
    }
}

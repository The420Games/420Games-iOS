//
//  Medication.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

let FTMedicationSavedNotificationName = "FTMedicationSavedNotification"
let FTMedicationDeletedNotificationName = "FTMedicationDeletedNotification"

enum MedicationType: String {
    case Smoke = "Smoke", Vape = "Vape", Edible = "Edible"
    static let allValues = [Smoke, Vape, Edible]
    
    func localizedString() -> String {
        
        switch self {
            
        case .Smoke: return NSLocalizedString("Smoke", comment: "Smoke medication type")
        case .Vape: return NSLocalizedString("Vape", comment: "Vape medication type")
        case .Edible: return NSLocalizedString("Edible", comment: "Edible medication type")
        default: return "\(self)"
        }
    }
}

enum MedicationMoodIndex: Int {
    case Poor = 0, Average = 1, Good = 2, Great = 3, High = 4, Stoned = 5
    static let allValues = [Poor, Average, Good, Great, High, Stoned]
    
    func localizedString() -> String {
        switch self {
        case .Poor: return NSLocalizedString("Poor", comment: "Poor mood index")
        case .Average: return NSLocalizedString("Average", comment: "Average mood index")
        case .Good: return NSLocalizedString("Good", comment: "Good mood index")
        case .Great: return NSLocalizedString("Great", comment: "Great mood index")
        case .High: return NSLocalizedString("High", comment: "High mood index")
        case .Stoned: return NSLocalizedString("Stoned", comment: "Stoned mood index")
        default: return "\(self)"
        }
    }
    
    func colorValue() -> UIColor {
        
        switch self {
        case .Poor: return UIColor.ftMoodColorValue0()
        case .Average: return UIColor.ftMoodColorValue1()
        case .Good: return UIColor.ftMoodColorValue2()
        case .Great: return UIColor.ftMoodColorValue3()
        case .High: return UIColor.ftMoodColorValue4()
        case .Stoned: return UIColor.ftMoodColorValue5()
        default: return UIColor.blackColor()
        }
    }
}

class Medication: FTDataObject {

    var activity: Activity?
    var dosage: NSNumber?
    var type: String?
    var mood: NSNumber?
}

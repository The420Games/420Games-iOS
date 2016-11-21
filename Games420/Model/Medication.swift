//
//  Medication.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

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
    case poor = 0, average = 1, good = 2, great = 3, high = 4, stoned = 5
    static let allValues = [poor, average, good, great, high, stoned]
    
    func localizedString() -> String {
        switch self {
        case .poor: return NSLocalizedString("Poor", comment: "Poor mood index")
        case .average: return NSLocalizedString("Average", comment: "Average mood index")
        case .good: return NSLocalizedString("Good", comment: "Good mood index")
        case .great: return NSLocalizedString("Great", comment: "Great mood index")
        case .high: return NSLocalizedString("High", comment: "High mood index")
        case .stoned: return NSLocalizedString("Stoned", comment: "Stoned mood index")
        default: return "\(self)"
        }
    }
    
    func colorValue() -> UIColor {
        
        switch self {
        case .poor: return UIColor.ftMoodColorValue0()
        case .average: return UIColor.ftMoodColorValue1()
        case .good: return UIColor.ftMoodColorValue2()
        case .great: return UIColor.ftMoodColorValue3()
        case .high: return UIColor.ftMoodColorValue4()
        case .stoned: return UIColor.ftMoodColorValue5()
        default: return UIColor.black
        }
    }
}

class Medication: FTDataObject {

    var activity: Activity?
    var dosage: NSNumber?
    var type: String?
    var mood: NSNumber?
}

//
//  Medication.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

enum MedicationType: String {
    case Smoke = "Smoke", Vape = "Vape", Edible = "Edible"
    static let allValues = [Smoke, Vape, Edible]
}

enum MedicationMoodIndex: Int {
    case Poor = 0, Average = 1, Good = 2, Great = 3, High = 4, Stoned = 5
    static let allValues = [Poor, Average, Good, Great, High, Stoned]
}

class Medication: FTDataObject {

    var activity: Activity?
    var dosage: NSNumber?
    var type: String?
    var mood: NSNumber?
}

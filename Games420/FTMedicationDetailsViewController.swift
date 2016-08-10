//
//  FTMedicationDetailsViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTMedicationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var medication: Medication!
    
    private let cellId = "medicationCell"
    
    enum FTMedicationDetailSection: Int {
        case activity = 0, medication
    }
    
    enum FTMedicationActivityTitle: Int {
        case type = 0, distance, duration, elevation, source
        static let count = 5
    }
    
    enum FTMedicationTitle: Int {
        case type = 0, dosage, mood
        static let count = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return medication.activity != nil ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if medication.activity != nil {
            return FTMedicationTitle.count
        }
        else if let sectionType = FTMedicationDetailSection(rawValue: section) {
            switch sectionType {
            case .activity: return FTMedicationActivityTitle.count
            case .medication: return FTMedicationTitle.count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! FTMedicationDetailCell
        
        var title = ""
        var value = ""
        
        if medication.activity == nil {
            title = medicationPropertyTitle(indexPath.row)
            value = medicationPropertyValue(medication, index: indexPath.row)
        }
        else {
            if let sectionType =  FTMedicationDetailSection(rawValue: indexPath.section) {
                switch sectionType {
                case .activity:
                    title = activityPropertyTitle(indexPath.row)
                    value = activityPropertyValue(medication.activity!, index: indexPath.row)
                case .medication:
                    title = medicationPropertyTitle(indexPath.row)
                    value = medicationPropertyValue(medication, index: indexPath.row)
                }
            }
        }
        
        cell.configureCell(title, value: value)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionType = FTMedicationDetailSection(rawValue: section) {
            switch sectionType {
            case .activity: return NSLocalizedString("Activity", comment: "Activity section title")
            case .medication: return NSLocalizedString("Medication", comment: "Medication section title")
            }
        }
        
        return nil
    }
    
    // MARK: - Data integration
    
    private func medicationPropertyValue(medication: Medication, index: Int) -> String {
        
        return ""
    }
    
    private func medicationPropertyTitle(index: Int) -> String {
        
        return ""
    }
    
    private func activityPropertyValue(activity: Activity, index: Int) -> String {
        
        return ""
    }
    
    private func activityPropertyTitle(index: Int) -> String {
        
        return ""
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

//
//  FTLogActivityViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTLogActivityViewController: UIViewController {
    
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var dosageTextView: UITextField!
    @IBOutlet weak var moodButton: UIButton!
    
    var activity: Activity?
    let medication = Medication()
    
    private let typePlaceholderLabel = NSLocalizedString("Select medication type", comment: "Medication type placeholder")
    private let moodPLaceHolderLabel = NSLocalizedString("Select mood", comment: "Mood placeholder")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Log activity", comment: "Log activity title")
        
        setupUI()
        
        loadActivityDetails()
        
        medication.activity = activity
        
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        activityLabel.text = NSLocalizedString("Activity", comment: "Activity details placeholder")
        
        dosageTextView.placeholder = NSLocalizedString("Enter dosage", comment: "Dosage placeholder")
        
        moodButton.setTitle(moodPLaceHolderLabel, forState: .Normal)
        
        typeButton.setTitle(typePlaceholderLabel, forState: .Normal)
        
        dosageTextView.text = nil
    }
    
    private func loadActivityDetails() {
        
        if activity != nil {
            activityLabel.text = "\(activity?.name) at \(activity?.startDate)\n\(activity?.type) Distance:\(activity?.distance) for \(activity?.elapsedTime)"
        }
    }
    
    // MARK: - Actions

    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select type", comment: "Medication type picker title"), message: nil, preferredStyle: .ActionSheet)
        for type in MedicationType.allValues {
            picker.addAction(UIAlertAction(title: "\(type)", style: .Default, handler: { (action) in
                self.medication.type = type
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func moodButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select mood", comment: "Mood index picker title"), message: nil, preferredStyle: .ActionSheet)
        for mood in MedicationMoodIndex.allValues {
            picker.addAction(UIAlertAction(title: "\(mood)", style: .Default, handler: { (action) in
                self.medication.mood = mood
                self.moodButton.setTitle("\(mood)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
    }
    
    // MARK: - Data integration
}

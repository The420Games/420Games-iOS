//
//  FTManualActivityTrackViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 28..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTManualActivityTrackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var elevationTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    private let activity = Activity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNextButton()
    }
    
    private func addNextButton() {
        
        let barItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next button title"), style: .Plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        navigationItem.rightBarButtonItem = barItem
    }
    
    func nextButtonPressed(sender: AnyObject) {
        
        if validData() {
            performSegueWithIdentifier("logActivity", sender: self)
        }
    }
    
    @IBAction func typeButtonPressed(sender: AnyObject) {
        
        let picker = UIAlertController(title: NSLocalizedString("Select Activity type", comment: "Activity type picker title"), message: nil, preferredStyle: .ActionSheet)
        for type in ActivityType.allValues {
            picker.addAction(UIAlertAction(title: "\(type)", style: .Default, handler: { (action) in
                self.activity.type = type.rawValue
                self.typeButton.setTitle("\(type)", forState: .Normal)
            }))
        }
        picker.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil))
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    private func validData() -> Bool {
        
        var errors = [String]()
        
        if activity.distance?.doubleValue <= 0 {
            errors.append(NSLocalizedString("Please set distance!", comment: "Missing distance error message"))
        }
        
        if activity.type == nil || activity.type!.isEmpty {
            errors.append(NSLocalizedString("Please set activity type", comment: "Missing activity type error message"))
        }
        
        if activity.elapsedTime?.doubleValue <= 0 {
            errors.append(NSLocalizedString("Please set activity duration", comment: "Missing duration error message"))
        }
        
        if errors.count > 0 {
            
            let alert = UIAlertController(title: nil, message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        return errors.count == 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logActivity" {
            (segue.destinationViewController as! FTLogActivityViewController).activity = self.activity
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let text = textField.text {
            
            let string = NSString(string: text)
            let number = NSNumber(double: string.doubleValue)
            
            if textField == distanceTextField {
                activity.distance = number
            }
            else if textField == durationTextField {
                activity.elapsedTime = number
            }
            else if textField == elevationTextField {
                activity.elevationGain = number
            }
        }
    }
}

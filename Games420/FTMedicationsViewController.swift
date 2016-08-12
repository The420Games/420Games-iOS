//
//  FTMedicationsViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import MBProgressHUD

class FTMedicationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addMedicationButton: UIButton!
    
    @IBOutlet weak var medicationsTableView: UITableView!
    
    private let medicationCellId = "medicationCell"
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    private var medications = [Medication]()
    
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - UI Customization
    
    private func setupTableView() {
        
        medicationsTableView.backgroundColor = UIColor.clearColor()
        medicationsTableView.tableFooterView = UIView()
    }
    
    private func setupFilter() {
        
        filterSegmentedControl.tintColor = UIColor.ftLimeGreen()
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.Bold, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ], forState: .Selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 11.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ], forState: .Normal)
        
        filterSegmentedControl.removeAllSegments()
        
        filterSegmentedControl.insertSegmentWithTitle(NSLocalizedString("ALL", comment: "All medications filter title"), atIndex: 0, animated: false)
        
        for type in ActivityType.allValues {
            
            var title: String!
            switch type {
            case .Ride: title = NSLocalizedString("BIKE RIDE", comment: "Bike ride title")
            case .Run: title = NSLocalizedString("RUNNING", comment: "Running title")
            case .Swim: title = NSLocalizedString("SWIMMING", comment: "Swimming title")
            default: title = "\(title)"
            }
            
            filterSegmentedControl.insertSegmentWithTitle(title, atIndex: filterSegmentedControl.numberOfSegments, animated: false)
        }
        
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Medications", comment: "Medications navigation item title")
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonPressed(_:)))
        
        setupTableView()
        
        setupFilter()
        
        filterSegmentedControl.selectedSegmentIndex = 0
        
        addMedicationButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("ADD NEW ACTIVITY", comment: "Add new medication button title"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func backButtonPressed(sender: AnyObject) {
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func addMedicationTouched(sender: AnyObject) {
    }
    
    @IBAction func filterChanged(sender: UISegmentedControl) {
    }
    // MARK: - Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(medicationCellId, forIndexPath: indexPath) as! FTMedicationListCell
        
        let medication = medications[indexPath.row]
        
        cell.setupCell(medication)
        
        return cell
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

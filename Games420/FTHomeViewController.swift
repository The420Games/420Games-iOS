//
//  FTHomeViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import XYPieChart

class FTHomeViewController: UIViewController, XYPieChartDelegate, XYPieChartDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var topSubtitleLabel: UILabel!
        
    @IBOutlet weak var pieChart: XYPieChart!
    
    @IBOutlet weak var pieInnerHolderView: UIView!
    @IBOutlet weak var pieTextHolderView: UIView!
    @IBOutlet weak var pieMonthLabel: UILabel!
    @IBOutlet weak var pieYearLabel: UILabel!
    
    @IBOutlet weak var moodCollectionView: UICollectionView!
    
    private let profileSegueId = "profile"
    private let medicationsSegueId = "medications"
    private let moodCellId = "moodCell"
    
    private lazy var moodValues: [MedicationMoodIndex: Int] = {
       
        var values = [MedicationMoodIndex: Int]()
        
        for index in MedicationMoodIndex.allValues {
            values[index] = 0
        }
        
        return values
    }()
    
    private lazy var currentMonth: Int = {
        
        let calendar = NSCalendar.currentCalendar()
        return calendar.component(.Month, fromDate: NSDate())
    }()
    
    private lazy var currentYear: Int = {
        
        let calendar = NSCalendar.currentCalendar()
        return calendar.component(.Year, fromDate: NSDate())
    }()
    
    private var isFetching = false
    
    // MARK: - Container Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        manageForMenuNotification(true)
        
        setupUI()
        
        pieChart.reloadData()
        
        fetchMedications()
        
        populuatePieLabelsData()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        setupPieInnerHolder()
    }
    
    deinit {
        
        manageForMenuNotification(false)
    }
    
    // MARK: - UI Customization
    
    private func setupPieChart() {
        
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.showPercentage = false
        pieChart.showLabel = false
        
        pieChart.backgroundColor = UIColor.clearColor()
    }
    
    private func setupPieInnerHolder() {
        
        pieInnerHolderView.backgroundColor = UIColor.clearColor()
        pieInnerHolderView.clipsToBounds = true
        pieInnerHolderView.layer.cornerRadius = pieInnerHolderView.bounds.size.width / 2
        pieInnerHolderView.layer.borderWidth = 6.0
        pieInnerHolderView.layer.borderColor = view.backgroundColor?.CGColor
        
        setupPieTextHolder()
    }
    
    private func setupPieTextHolder() {
        
        pieTextHolderView.backgroundColor = view.backgroundColor
        pieTextHolderView.clipsToBounds = true
        pieTextHolderView.layer.cornerRadius = pieTextHolderView.bounds.size.width / 2
        
        setupPieLabels()
    }
    
    private func setupPieLabels() {
        
        let monthSize = max(pieTextHolderView.bounds.size.width * 0.126, 10.0)
        pieMonthLabel.font = UIFont.defaultFont(.Bold, size: monthSize)
        pieMonthLabel.textColor = UIColor.whiteColor()
        
        pieYearLabel.font = UIFont.defaultFont(.Light, size: max(monthSize * 0.75, 7.5))
        pieMonthLabel.textColor = UIColor.whiteColor()
    }
    
    private func setupTopTitleLabels() {
        
        topTitleLabel.font = UIFont.defaultFont(.Bold, size: 15.0)
        topTitleLabel.textColor = UIColor.whiteColor()
        topTitleLabel.text = NSLocalizedString("MOOD", comment: "Mood top title")
        
        topSubtitleLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        topSubtitleLabel.textColor = UIColor.whiteColor()
        topSubtitleLabel.text = NSLocalizedString("Monthly data (%)", comment: "Monthly data title")
    }
    
    private func setupCollectionView() {
        
        moodCollectionView.backgroundColor = UIColor.clearColor()
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupPieChart()
        
        setupCollectionView()
        
        setupTopTitleLabels()
    }

    // MARK: - Notifications
    
    private func manageForMenuNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.menuItemSelectedNotificationReceived(_:)), name: FTSlideMenuItemSelectedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTSlideMenuItemSelectedNotificationName, object: nil)
        }
    }
    
    func menuItemSelectedNotificationReceived(notification: NSNotification) {
        
        if let index = notification.userInfo?["itemIndex"] as? Int {
            
            if let item = FTSlideMenuItem(rawValue: index) {
                
                switch item {
                case .Profile: performSegueWithIdentifier(profileSegueId, sender: self)
                case .Main: navigationController?.popToRootViewControllerAnimated(true)
                case .Workouts: performSegueWithIdentifier(medicationsSegueId, sender: self)
                default: print("Implement menu for \(item)")
                }
            }
        }
    }
    
    // MARK: - Pie Chart
    
    func numberOfSlicesInPieChart(pieChart: XYPieChart!) -> UInt {
        
        return  UInt(moodValues.count)
    }
    
    func pieChart(pieChart: XYPieChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        
        if let mood = MedicationMoodIndex(rawValue: Int(index)) {
            
            if let value = moodValues[mood] {
                
                return CGFloat(value)
            }
        }
        
        return 0.0
    }
    
    func pieChart(pieChart: XYPieChart!, colorForSliceAtIndex index: UInt) -> UIColor! {
        
        if let mood = MedicationMoodIndex(rawValue: Int(index)) {
            
            return mood.colorValue()
        }
        
        return UIColor.blackColor()
    }
    
    func pieChart(pieChart: XYPieChart!, textForSliceAtIndex index: UInt) -> String! {
        
        if let mood = MedicationMoodIndex(rawValue: Int(index)) {
            
            return mood.localizedString()
        }
        
        return ""
    }
    
    // MARK: - CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return moodValues.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(moodCellId, forIndexPath: indexPath) as! FTMoodValueCell
        
        if let mood = MedicationMoodIndex(rawValue: indexPath.item) {
            if let value = moodValues[mood] {
                cell.setupCell(mood, value: value)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: max(collectionView.bounds.size.width / CGFloat(max(moodValues.count, 1)), 1.0), height: collectionView.bounds.size.height)
    }
    
    // MARK: - Data integration
    
    private func populuatePieLabelsData() {
        
        let formatter = NSDateFormatter()
        let name = formatter.monthSymbols[currentMonth]
        pieMonthLabel.text = name.uppercaseString
        
        pieYearLabel.text = "\(currentYear)"
    }
    
    private func fetchMedications() {
        
        if !isFetching {
            
            isFetching = true
            
            var nextMonth = currentMonth + 1
            var nextYear = currentYear
            if currentMonth > 12 {
                nextYear += 1
                nextMonth = 1
            }
            
            let calendar = NSCalendar.currentCalendar()
            
            let comps = NSDateComponents()
            
            comps.year = currentYear
            comps.month = currentMonth
            comps.day = 1
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            
            let startDate = calendar.dateFromComponents(comps)
            
            comps.year = nextYear
            comps.month = nextMonth
            comps.day = 1
            comps.hour = 23
            comps.minute = 59
            comps.second = 59
            
            let finishDate = calendar.dateFromComponents(comps)?.dateByAddingTimeInterval(-1 * 24 * 60 * 60)

            var query = "ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'"
            
            //query += " AND activity.startDate >= \(startDate!.timeIntervalSince1970) AND activity.startDate <= \(finishDate!.timeIntervalSince1970)"
            
            Medication.findObjects(query, order: ["updated desc"], offset: 0, limit: 100) { (objects, error) in
                
                if objects != nil {
                
                    var values = [MedicationMoodIndex: Int]()
                    
                    for index in MedicationMoodIndex.allValues {
                        values[index] = 0
                    }
                    
                    for medication in objects as! [Medication] {
                        
                        if medication.mood != nil {
                            
                            if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                                if var value = values[mood] {
                                    value += 1
                                    values[mood] = value
                                }
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.isFetching = false
                        self.moodValues = values
                        
                        self.pieChart.reloadData()
                        self.moodCollectionView.reloadData()
                    })
                }
            }
        }
    }
}

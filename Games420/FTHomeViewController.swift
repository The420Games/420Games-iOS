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
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var addActivityButton: UIButton!
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var topSubtitleLabel: UILabel!
    
    @IBOutlet weak var pieChart: XYPieChart!
    
    @IBOutlet weak var pieInnerHolderView: UIView!
    @IBOutlet weak var pieTextHolderView: UIView!
    @IBOutlet weak var pieMonthLabel: UILabel!
    @IBOutlet weak var pieYearLabel: UILabel!
    
    @IBOutlet weak var moodCollectionView: UICollectionView!
    
    @IBOutlet weak var bottomHorizontalLine: UIView!
    @IBOutlet weak var bottomHorizontalLineHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var bottomSubtitleLabel: UILabel!
    
    @IBOutlet weak var lineChartHolder: UIView!
    
    private var lineChart: LineChart!
    
    private let profileSegueId = "profile"
    private let medicationsSegueId = "medications"
    private let moodCellId = "moodCell"
    
    private var activityDistances: [CGFloat]!
    private var lineChartXLabels: [String]!
    
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
    
    enum FTHomeScreenStatus {
        case Loading, NoActivities, Normal
    }
    
    var status: FTHomeScreenStatus  {
        didSet {
            if self.isViewLoaded() {
                switch self.status {
                case .Loading:
                    self.statusLabel.text = NSLocalizedString("Fetching data...", comment: "Home screen status label title fetching data")
                    self.statusLabel.hidden = false
                    self.addActivityButton.hidden = true
                    self.pieChart.hidden = true
                    self.moodCollectionView.hidden = true
                    self.lineChartHolder.hidden = true
                    self.topTitleLabel.hidden = true
                    self.topSubtitleLabel.hidden = true
                    self.bottomTitleLabel.hidden = true
                    self.bottomTitleLabel.hidden = true
                    self.bottomHorizontalLine.hidden = true
                case .NoActivities:
                    self.statusLabel.text = NSLocalizedString("No activities found... Do you want to add one?", comment: "Home screen status label title no data")
                    self.statusLabel.hidden = false
                    self.addActivityButton.hidden = false
                    self.pieChart.hidden = true
                    self.moodCollectionView.hidden = true
                    self.lineChartHolder.hidden = true
                    self.topTitleLabel.hidden = true
                    self.topSubtitleLabel.hidden = true
                    self.bottomTitleLabel.hidden = true
                    self.bottomTitleLabel.hidden = true
                    self.bottomHorizontalLine.hidden = true
                case .Normal:
                    self.statusLabel.hidden = true
                    self.addActivityButton.hidden = true
                    self.pieChart.hidden = false
                    self.moodCollectionView.hidden = false
                    self.lineChartHolder.hidden = false
                    self.topTitleLabel.hidden = false
                    self.topSubtitleLabel.hidden = false
                    self.bottomTitleLabel.hidden = false
                    self.bottomTitleLabel.hidden = false
                    self.bottomHorizontalLine.hidden = false
                }
            }
        }
    }
    
    // MARK: - Container Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        
        status = .NoActivities
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        manageForMenuNotification(true)
        
        setupUI()
        
        status = .NoActivities
        
        fetchMedications()
        
        populatePieLabelsData()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        setupPieInnerHolder()
        
//        setupLineChart()
    }
    
    deinit {
        
        manageForMenuNotification(false)
    }
    
    // MARK: - UI Customization
    
    private func setupStatusViews() {
        
        statusLabel.font = UIFont.defaultFont(.Medium, size: 15.0)
        statusLabel.textColor = UIColor.whiteColor()
        
        addActivityButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("ADD NEW ACTIVITY", comment: "Add new activity button title on home screen"))
    }
    
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
        
        let monthSize = max(pieTextHolderView.bounds.size.width * 0.15, 11.0)
        pieMonthLabel.font = UIFont.defaultFont(.Bold, size: monthSize)
        pieMonthLabel.textColor = UIColor.whiteColor()
        
        pieYearLabel.font = UIFont.defaultFont(.Light, size: max(monthSize * 0.75, 9.0))
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
    
    private func setupLineChart() {

        if lineChart != nil {
            lineChart.removeFromSuperview()
            lineChart = nil
        }
    
        if lineChart == nil {
            
            lineChart = LineChart(frame: CGRect(x: 0, y: 0, width: lineChartHolder.bounds.size.width, height: lineChartHolder.bounds.size.height))
            lineChart.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            lineChartHolder.addSubview(lineChart)
            lineChart.backgroundColor = UIColor.clearColor()
            lineChartHolder.backgroundColor = UIColor.clearColor()
            
            lineChart.x.grid.visible = false
            lineChart.x.axis.visible = false
            lineChart.x.labels.visible = true
            lineChart.x.labels.values = lineChartXLabels
            lineChart.x.labels.color = UIColor.whiteColor()
            lineChart.x.labels.font = UIFont.defaultFont(.Light, size: 10.0)!
            
            lineChart.y.grid.visible = false
            lineChart.y.axis.visible = false
            lineChart.y.labels.visible = true
            lineChart.y.labels.color = UIColor.whiteColor()
            lineChart.y.labels.font = UIFont.defaultFont(.Light, size: 10.0)!
            
            lineChart.dots.color = UIColor.ftLimeGreen()
            lineChart.dots.innerRadius = 6.0
            lineChart.dots.outerRadius = 10.0
            
            lineChart.area = false
            lineChart.colors = [UIColor.ftLimeGreen()]
            lineChart.dotColors = [view.backgroundColor!]
        }

        lineChart.addLine(activityDistances)
    }
    
    private func setupLineChartLabels() {
        
        bottomTitleLabel.font = UIFont.defaultFont(.Bold, size: 15.0)
        bottomTitleLabel.textColor = UIColor.whiteColor()
        bottomTitleLabel.text = NSLocalizedString("DISTANCE", comment: "Distance top title")
        
        bottomSubtitleLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        bottomSubtitleLabel.textColor = UIColor.whiteColor()
        bottomSubtitleLabel.text = ""
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupStatusViews()
        
        setupPieChart()
        
        setupCollectionView()
        
        bottomHorizontalLine.backgroundColor = UIColor.ftMidGray()
        bottomHorizontalLineHeight.constant = 0.5
        
        setupTopTitleLabels()
        
        setupLineChartLabels()
    }
    
    // MARK: - Actions
    
    @IBAction func addActivityButtonTouched(sender: AnyObject) {
        
        performSegueWithIdentifier(medicationsSegueId, sender: NSNumber(bool: true))
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == medicationsSegueId {
            
            if let addNewMedication = sender as? NSNumber {
                
                (segue.destinationViewController as! FTMedicationsViewController).shouldAddNewActivityOnShow = addNewMedication.boolValue
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
    
    private func populatePieLabelsData() {
        
        let formatter = NSDateFormatter()
        let name = formatter.monthSymbols[currentMonth - 1]
        pieMonthLabel.text = name.uppercaseString
        
        pieYearLabel.text = "\(currentYear)"
    }
    
    private func populateLineChartLabelsData() {
        
        let unit = Activity.distanceUnit()
        
        bottomSubtitleLabel.text = String(format: NSLocalizedString("Past %d activities (%@)", comment: "Monthly distance format"), activityDistances.count, unit)
    }
    
    private func fetchMedications() {
        
        if status != .Loading {
            
            status = .Loading
            
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
            
            query += " AND activity.startDate >= \(startDate!.timeIntervalSince1970) AND activity.startDate <= \(finishDate!.timeIntervalSince1970)"
            
            Medication.findObjects(query, order: ["created desc"], offset: 0, limit: 100) { (objects, error) in
                
                if objects != nil {
                    
                    let sortedMedications = (objects as! [Medication]).sort({ (medication1, medication2) -> Bool in
                        if medication1.activity != nil && medication2.activity != nil {
                            if medication1.activity!.startDate != nil && medication2.activity!.startDate != nil {
                                return medication1.activity!.startDate!.compare(medication2.activity!.startDate!) == .OrderedAscending
                            }
                        }
                        return false
                    })
                
                    var values = [MedicationMoodIndex: Int]()
                    var xLabels = [String]()
                    
                    for index in MedicationMoodIndex.allValues {
                        values[index] = 0
                    }
                    
                    var distances = [CGFloat]()
                    
                    let distanceDivider = Activity.isMetricSystem() ? Activity.metersInMile : 1000
                    
                    var index = 0
                    
                    let calendar = NSCalendar.currentCalendar()
                    
                    for medication in sortedMedications {
                        
                        if medication.mood != nil {
                            
                            if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                                if var value = values[mood] {
                                    value += 1
                                    values[mood] = value
                                }
                            }
                        }
                        
                        if medication.activity != nil {
                            
                            if medication.activity!.distance != nil {
                                
                                let distance = CGFloat(medication.activity!.distance!.doubleValue / distanceDivider)
                                distances.append(distance)
                                
                                if medication.activity!.startDate != nil {
                                    
                                    let day = calendar.component(.Day, fromDate: medication.activity!.startDate!)
                                    xLabels.append("\(day)")
                                }
                                else {
                                    xLabels.append("\(index + 1)")
                                }
                                
                                index += 1
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if objects != nil && objects!.count > 0 {
                            self.status = .Normal
                        }
                        else {
                            self.status = .NoActivities
                        }
                        self.moodValues = values
                        
                        self.pieChart.reloadData()
                        self.moodCollectionView.reloadData()
                        
                        if distances.count > 0 {
                            
                            self.activityDistances = distances
                            self.lineChartXLabels = xLabels
                            
                            self.populateLineChartLabelsData()
                            self.setupLineChart()
                        }
                    })
                }
                else {
                    self.status = .NoActivities
                }
            }
        }
    }
}

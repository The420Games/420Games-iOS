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
    
    @IBOutlet weak var pieChartHolder: UIView!
    
    @IBOutlet weak var pieInnerHolderView: UIView!
    @IBOutlet weak var pieTextHolderView: UIView!
    @IBOutlet weak var pieMonthLabel: UILabel!
    @IBOutlet weak var pieYearLabel: UILabel!
    
    @IBOutlet weak var moodCollectionView: UICollectionView!
    
    @IBOutlet weak var bottomHorizontalLine: UIView!
    @IBOutlet weak var bottomHorizontalLineHeight: NSLayoutConstraint!
        
    @IBOutlet var dotViews: [UIView]!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var bottomSubtitleLabel: UILabel!
    
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var elevationTitleLabel: UILabel!
    @IBOutlet weak var lineChartHolder: UIView!
    
    private var pieChart: XYPieChart!
    
    private var lineChart: LineChart!
    
    private let profileSegueId = "profile"
    private let medicationsSegueId = "medications"
    private let tutorialSegueId = "tutorial"
    
    private let moodCellId = "activityCell"
    
    private var activityDistances: [CGFloat]!
    private var activityElevations: [CGFloat]!
    private var activityDurations: [CGFloat]!
    private var lineChartXLabels: [String]!
    
    private struct ActivityData {
        
        var totalCount:Int = 0
        var totalDuration: Double = 0.0
    }
    
    private lazy var activityValues: [ActivityType: ActivityData] = {
       
        var values = [ActivityType: ActivityData]()
        
        for type in ActivityType.allValues {
            values[type] = ActivityData(totalCount: 0, totalDuration: 0.0)
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
                    self.pieChartHolder.hidden = true
                    self.moodCollectionView.hidden = true
                    self.lineChartHolder.hidden = true
                    self.topTitleLabel.hidden = true
                    self.topSubtitleLabel.hidden = true
                    self.durationTitleLabel.hidden = true
                    self.elevationTitleLabel.hidden = true
                    self.distanceTitleLabel.hidden = true
                    self.bottomSubtitleLabel.hidden = true
                    self.bottomHorizontalLine.hidden = true
                    for dot in dotViews {
                        dot.hidden = true
                    }
                case .NoActivities:
                    self.statusLabel.text = NSLocalizedString("No activities found... Do you want to add one?", comment: "Home screen status label title no data")
                    self.statusLabel.hidden = false
                    self.addActivityButton.hidden = false
                    self.pieChartHolder.hidden = true
                    self.moodCollectionView.hidden = true
                    self.lineChartHolder.hidden = true
                    self.topTitleLabel.hidden = true
                    self.topSubtitleLabel.hidden = true
                    self.durationTitleLabel.hidden = true
                    self.elevationTitleLabel.hidden = true
                    self.distanceTitleLabel.hidden = true
                    self.bottomSubtitleLabel.hidden = true
                    self.bottomHorizontalLine.hidden = true
                    for dot in dotViews {
                        dot.hidden = true
                    }
                case .Normal:
                    self.statusLabel.hidden = true
                    self.addActivityButton.hidden = true
                    self.pieChartHolder.hidden = false
                    self.moodCollectionView.hidden = false
                    self.lineChartHolder.hidden = false
                    self.topTitleLabel.hidden = false
                    self.topSubtitleLabel.hidden = false
                    self.durationTitleLabel.hidden = false
                    self.elevationTitleLabel.hidden = false
                    self.distanceTitleLabel.hidden = false
                    self.bottomSubtitleLabel.hidden = false
                    self.bottomHorizontalLine.hidden = false
                    for dot in dotViews {
                        dot.hidden = false
                    }
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
        
        manageForMedicationNotification(true)
        
        manageForLoginNotification(true)
        
        setupUI()
        
        status = .NoActivities
        
        fetchMedications()
        
        populatePieLabelsData()
        
        FTAnalytics.trackEvent(.Home, data: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        setupPieChart()
        
        setupPieInnerHolder()
        
        setupLineChartLabels()
    }
    
    deinit {
        
        manageForMenuNotification(false)
        
        manageForMedicationNotification(false)
        
        manageForLoginNotification(false)
    }
    
    // MARK: - UI Customization
    
    private func setupStatusViews() {
        
        statusLabel.font = UIFont.defaultFont(.Medium, size: 15.0)
        statusLabel.textColor = UIColor.whiteColor()
        
        addActivityButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("ADD NEW ACTIVITY", comment: "Add new activity button title on home screen"))
    }
    
    private func setupPieChart() {
        
        pieChartHolder.backgroundColor = UIColor.clearColor()
        
        pieChart = XYPieChart(frame: CGRect(x: 0, y: 0, width: pieChartHolder.bounds.size.width, height: pieChartHolder.bounds.size.height))
        
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.showPercentage = false
        pieChart.showLabel = false
        
        pieChart.backgroundColor = UIColor.clearColor()
        
        pieChartHolder.insertSubview(pieChart, atIndex: 0)
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
            
            lineChart = LineChart(frame: CGRect(x: 15, y: 0, width: lineChartHolder.bounds.size.width - 15, height: lineChartHolder.bounds.size.height))
            lineChart.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            lineChartHolder.addSubview(lineChart)
            lineChart.backgroundColor = UIColor.clearColor()
            lineChartHolder.backgroundColor = UIColor.clearColor()
            
            lineChart.x.grid.visible = false
            lineChart.x.axis.visible = false
            lineChart.x.labels.visible = true
            lineChart.x.labels.values = lineChartXLabels
            lineChart.x.labels.color = UIColor.whiteColor()
            lineChart.x.labels.font = UIFont.defaultFont(.Light, size: 9.0)!
            
            lineChart.y.grid.visible = false
            lineChart.y.axis.visible = false
            lineChart.y.axis.inset = 30.0
            lineChart.y.labels.visible = true
            lineChart.y.labels.color = UIColor.whiteColor()
            lineChart.y.labels.font = UIFont.defaultFont(.Light, size: 9.0)!
            
            lineChart.dots.color = UIColor.redColor()
            lineChart.dots.innerRadius = 6.0
            lineChart.dots.outerRadius = 10.0
            
            lineChart.area = false
            lineChart.colors = [UIColor.ftDistanceColor(), UIColor.ftElevationColor(), UIColor.ftDurationColor()]
            lineChart.dotColors = [view.backgroundColor!, view.backgroundColor!, view.backgroundColor!]
        }

        lineChart.addLine(activityDistances)
        lineChart.addLine(activityElevations)
        lineChart.addLine(activityDurations)
    }
    
    private func setupLineChartLabels() {
        
        let fontSize = min(view.bounds.size.width / 31, 15.0)
        let legendFont = UIFont.defaultFont(.Bold, size: fontSize)
        let legendColor = UIColor.whiteColor()
        
        distanceTitleLabel.font = legendFont
        distanceTitleLabel.textColor = legendColor
        distanceTitleLabel.text = NSLocalizedString("DISTANCE", comment: "Distance chart title") + " (\(Activity.distanceUnit(true)))"
        
        elevationTitleLabel.font = legendFont
        elevationTitleLabel.textColor = legendColor
        elevationTitleLabel.text = NSLocalizedString("ELEVATION", comment: "Elevation chart title") + " (\(Activity.elevationUnit(true)))"
        
        durationTitleLabel.font = legendFont
        durationTitleLabel.textColor = legendColor
        durationTitleLabel.text = NSLocalizedString("DURATION", comment: "Duration chart title") + " (" + NSLocalizedString("min", comment: "Minutes abbreviation") + ")"
        
        dotViews[0].backgroundColor = UIColor.ftDistanceColor()
        dotViews[1].backgroundColor = UIColor.ftElevationColor()
        dotViews[2].backgroundColor = UIColor.ftDurationColor()
        
        for dot in dotViews {
            dot.clipsToBounds = true
            dot.layer.cornerRadius = dot.frame.size.width / 2
        }
        
        bottomSubtitleLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        bottomSubtitleLabel.textColor = UIColor.whiteColor()
        bottomSubtitleLabel.text = NSLocalizedString("Weekly data", comment: "Line chart bottom subtitle")
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupStatusViews()
        
        setupPieChart()
        
        setupCollectionView()
        
        bottomHorizontalLine.backgroundColor = UIColor.ftMidGray()
        bottomHorizontalLineHeight.constant = 0.5
        
        setupTopTitleLabels()
    }
    
    // MARK: - Actions
    
    @IBAction func addActivityButtonTouched(sender: AnyObject) {
        
        FTAnalytics.trackEvent(.NewActivityFromHome, data: nil)
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
                case .Tutorial: performSegueWithIdentifier(tutorialSegueId, sender: self)
                case .FAQ: openLink(FTFAQLink)
                case .Terms: openLink(FTTermsAndConditionsLink)
                default: print("Implement menu for \(item)")
                }
            }
        }
    }
    
    private func manageForMedicationNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.medicationChangedNotificationReceived(_:)), name: FTMedicationSavedNotificationName, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.medicationChangedNotificationReceived(_:)), name: FTMedicationDeletedNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTMedicationSavedNotificationName, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTMedicationDeletedNotificationName, object: nil)
        }
    }
    
    func medicationChangedNotificationReceived(notification: NSNotification) {
        
        fetchMedications()
    }
    
    private func manageForLoginNotification(signup: Bool) {
        
        if signup {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loginNotificationReceived(_:)), name: FTSignedInNotificationName, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: FTSignedInNotificationName, object: nil)
        }
    }
    
    func loginNotificationReceived(notification: NSNotification) {
        
        fetchMedications()
    }
    
    func openLink(linkStr: String) {
        
        if let url = NSURL(string: linkStr) {
            
            if UIApplication.sharedApplication().canOpenURL(url) {
                
                UIApplication.sharedApplication().openURL(url)
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
        
        return  UInt(activityValues.count)
    }
    
    func pieChart(pieChart: XYPieChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        
        let activityType = ActivityType.allValues[Int(index)]
            
        if let data = activityValues[activityType] {
            
            return CGFloat(data.totalDuration)
        }
        
        return 0.0
    }
    
    func pieChart(pieChart: XYPieChart!, colorForSliceAtIndex index: UInt) -> UIColor! {
        
        let activityType = ActivityType.allValues[Int(index)]
        
        return activityType.color()
    }
    
    func pieChart(pieChart: XYPieChart!, textForSliceAtIndex index: UInt) -> String! {
        
        return ""
    }
    
    // MARK: - CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return activityValues.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(moodCellId, forIndexPath: indexPath) as! FTActivityValueCell
        
        let activityType = ActivityType.allValues[indexPath.item]
        if let data = activityValues[activityType] {
            cell.setupCell(activityType, value: data.totalCount)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: max(collectionView.bounds.size.width / CGFloat(max(activityValues.count, 1)), 1.0), height: collectionView.bounds.size.height)
    }
    
    // MARK: - Data integration
    
    private func populatePieLabelsData() {
        
        let formatter = NSDateFormatter()
        let name = formatter.monthSymbols[currentMonth - 1]
        pieMonthLabel.text = name.uppercaseString
        
        pieYearLabel.text = "\(currentYear)"
    }
    
    private func fetchMedications() {
        
        if status != .Loading && FTDataManager.sharedInstance.currentUser != nil {
            
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
            
            query += " AND activity.startDate >= \(startDate!.timeIntervalSince1970 * 1000) AND activity.startDate <= \(finishDate!.timeIntervalSince1970 * 1000)"
            
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
                
                    var values = [ActivityType: ActivityData]()
                    let xLabels = ["1", "2", "3", "4"]
                    
                    for type in ActivityType.allValues {
                        values[type] = ActivityData(totalCount: 0, totalDuration: 0.0)
                    }
                    
                    var distances: [CGFloat] = [0, 0, 0,0]
                    var durations: [CGFloat] = [0, 0, 0,0]
                    var elevations: [CGFloat] = [0, 0, 0,0]
                    
                    let distanceDivider = Activity.isMetricSystem() ? Activity.metersInMile : 1000.0
                    let elevationDivider = Activity.isMetricSystem() ? Activity.metersInFoot : 1.0
                    let durationDivider = 60.0 // Mins
                    
                    var index = 0
                    
                    let calendar = NSCalendar.currentCalendar()
                    
                    for medication in sortedMedications {
                        
                        if medication.activity != nil {
                            
                            let duration: Double = medication.activity!.elapsedTime != nil ? medication.activity!.elapsedTime!.doubleValue / durationDivider : 0.0
                            let distance: Double = medication.activity!.distance != nil ? medication.activity!.distance!.doubleValue / distanceDivider : 0.0
                            let elevation: Double = medication.activity!.elevationGain != nil ? medication.activity!.elevationGain!.doubleValue / elevationDivider : 0.0
                            
                            if medication.activity!.type != nil {
                                
                                if let activityType = ActivityType(rawValue: medication.activity!.type!) {
                                    if var data = values[activityType] {
                                        data.totalCount += 1
                                        data.totalDuration += duration
                                        values[activityType] = data
                                    }
                                }
                            }
                            
                            var day = 1
                            
                            if medication.activity!.startDate != nil {
                                
                                day = calendar.component(.Day, fromDate: medication.activity!.startDate!)
                            }
                            
                            if day <= 7 {
                                index = 0
                            }
                            else if index <= 14 {
                                index = 1
                            }
                            else if index <= 21 {
                                index = 2
                            }
                            else {
                                index = 3
                            }
                            
                            distances[index] += CGFloat(distance)
                            durations[index] += CGFloat(duration)
                            elevations[index] += CGFloat(elevation)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if objects != nil && objects!.count > 0 {
                            self.status = .Normal
                        }
                        else {
                            self.status = .NoActivities
                        }
                        self.activityValues = values
                        
                        self.pieChart.reloadData()
                        self.moodCollectionView.reloadData()
                        
                        if distances.count > 0 || elevations.count > 0 || durations.count > 0 {
                            
                            self.activityDistances = distances
                            self.activityDurations = durations
                            self.activityElevations = elevations
                            self.lineChartXLabels = xLabels
                            
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

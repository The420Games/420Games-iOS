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
    
    fileprivate var pieChart: XYPieChart!
    
    fileprivate var lineChart: LineChart!
    
    fileprivate let profileSegueId = "profile"
    fileprivate let medicationsSegueId = "medications"
    fileprivate let tutorialSegueId = "tutorial"
    
    fileprivate let moodCellId = "activityCell"
    
    fileprivate var activityDistances: [CGFloat]!
    fileprivate var activityElevations: [CGFloat]!
    fileprivate var activityDurations: [CGFloat]!
    fileprivate var lineChartXLabels: [String]!
    
    fileprivate struct ActivityData {
        
        var totalCount:Int = 0
        var totalDuration: Double = 0.0
    }
    
    fileprivate lazy var activityValues: [ActivityType: ActivityData] = {
       
        var values = [ActivityType: ActivityData]()
        
        for type in ActivityType.allValues {
            values[type] = ActivityData(totalCount: 0, totalDuration: 0.0)
        }
        
        return values
    }()
    
    fileprivate lazy var currentMonth: Int = {
        
        let calendar = Calendar.current
        return (calendar as NSCalendar).component(.month, from: Date())
    }()
    
    fileprivate lazy var currentYear: Int = {
        
        let calendar = Calendar.current
        return (calendar as NSCalendar).component(.year, from: Date())
    }()
    
    enum FTHomeScreenStatus {
        case loading, noActivities, normal
    }
    
    var status: FTHomeScreenStatus  {
        didSet {
            if self.isViewLoaded {
                switch self.status {
                case .loading:
                    self.statusLabel.text = NSLocalizedString("Fetching data...", comment: "Home screen status label title fetching data")
                    self.statusLabel.isHidden = false
                    self.addActivityButton.isHidden = true
                    self.pieChartHolder.isHidden = true
                    self.moodCollectionView.isHidden = true
                    self.lineChartHolder.isHidden = true
                    self.topTitleLabel.isHidden = true
                    self.topSubtitleLabel.isHidden = true
                    self.durationTitleLabel.isHidden = true
                    self.elevationTitleLabel.isHidden = true
                    self.distanceTitleLabel.isHidden = true
                    self.bottomSubtitleLabel.isHidden = true
                    self.bottomHorizontalLine.isHidden = true
                    for dot in dotViews {
                        dot.isHidden = true
                    }
                case .noActivities:
                    self.statusLabel.text = NSLocalizedString("No activities found... Do you want to add one?", comment: "Home screen status label title no data")
                    self.statusLabel.isHidden = false
                    self.addActivityButton.isHidden = false
                    self.pieChartHolder.isHidden = true
                    self.moodCollectionView.isHidden = true
                    self.lineChartHolder.isHidden = true
                    self.topTitleLabel.isHidden = true
                    self.topSubtitleLabel.isHidden = true
                    self.durationTitleLabel.isHidden = true
                    self.elevationTitleLabel.isHidden = true
                    self.distanceTitleLabel.isHidden = true
                    self.bottomSubtitleLabel.isHidden = true
                    self.bottomHorizontalLine.isHidden = true
                    for dot in dotViews {
                        dot.isHidden = true
                    }
                case .normal:
                    self.statusLabel.isHidden = true
                    self.addActivityButton.isHidden = true
                    self.pieChartHolder.isHidden = false
                    self.moodCollectionView.isHidden = false
                    self.lineChartHolder.isHidden = false
                    self.topTitleLabel.isHidden = false
                    self.topSubtitleLabel.isHidden = false
                    self.durationTitleLabel.isHidden = false
                    self.elevationTitleLabel.isHidden = false
                    self.distanceTitleLabel.isHidden = false
                    self.bottomSubtitleLabel.isHidden = false
                    self.bottomHorizontalLine.isHidden = false
                    for dot in dotViews {
                        dot.isHidden = false
                    }
                }
            }
        }
    }
    
    // MARK: - Container Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        
        status = .noActivities
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        manageForMenuNotification(true)
        
        manageForMedicationNotification(true)
        
        manageForLoginNotification(true)
        
        setupUI()
        
        status = .noActivities
        
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
    
    fileprivate func setupStatusViews() {
        
        statusLabel.font = UIFont.defaultFont(.medium, size: 15.0)
        statusLabel.textColor = UIColor.white
        
        addActivityButton.ft_setupButton(UIColor.ftLimeGreen(), title: NSLocalizedString("ADD NEW ACTIVITY", comment: "Add new activity button title on home screen"))
    }
    
    fileprivate func setupPieChart() {
        
        pieChartHolder.backgroundColor = UIColor.clear
        
        pieChart = XYPieChart(frame: CGRect(x: 0, y: 0, width: pieChartHolder.bounds.size.width, height: pieChartHolder.bounds.size.height))
        
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.showPercentage = false
        pieChart.showLabel = false
        
        pieChart.backgroundColor = UIColor.clear
        
        pieChartHolder.insertSubview(pieChart, at: 0)
    }
    
    fileprivate func setupPieInnerHolder() {
        
        pieInnerHolderView.backgroundColor = UIColor.clear
        pieInnerHolderView.clipsToBounds = true
        pieInnerHolderView.layer.cornerRadius = pieInnerHolderView.bounds.size.width / 2
        pieInnerHolderView.layer.borderWidth = 6.0
        pieInnerHolderView.layer.borderColor = view.backgroundColor?.cgColor
        
        setupPieTextHolder()
    }
    
    fileprivate func setupPieTextHolder() {
        
        pieTextHolderView.backgroundColor = view.backgroundColor
        pieTextHolderView.clipsToBounds = true
        pieTextHolderView.layer.cornerRadius = pieTextHolderView.bounds.size.width / 2
        
        setupPieLabels()
    }
    
    fileprivate func setupPieLabels() {
        
        let monthSize = max(pieTextHolderView.bounds.size.width * 0.15, 11.0)
        pieMonthLabel.font = UIFont.defaultFont(.bold, size: monthSize)
        pieMonthLabel.textColor = UIColor.white
        
        pieYearLabel.font = UIFont.defaultFont(.light, size: max(monthSize * 0.75, 9.0))
        pieMonthLabel.textColor = UIColor.white
    }
    
    fileprivate func setupTopTitleLabels() {
        
        topTitleLabel.font = UIFont.defaultFont(.bold, size: 15.0)
        topTitleLabel.textColor = UIColor.white
        topTitleLabel.text = NSLocalizedString("MOOD", comment: "Mood top title")
        
        topSubtitleLabel.font = UIFont.defaultFont(.light, size: 13.0)
        topSubtitleLabel.textColor = UIColor.white
        topSubtitleLabel.text = NSLocalizedString("Monthly data (%)", comment: "Monthly data title")
    }
    
    fileprivate func setupCollectionView() {
        
        moodCollectionView.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupLineChart() {

        if lineChart != nil {
            lineChart.removeFromSuperview()
            lineChart = nil
        }
    
        if lineChart == nil {
            
            lineChart = LineChart(frame: CGRect(x: 15, y: 0, width: lineChartHolder.bounds.size.width - 15, height: lineChartHolder.bounds.size.height))
            lineChart.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            lineChartHolder.addSubview(lineChart)
            lineChart.backgroundColor = UIColor.clear
            lineChartHolder.backgroundColor = UIColor.clear
            
            lineChart.x.grid.visible = false
            lineChart.x.axis.visible = false
            lineChart.x.labels.visible = true
            lineChart.x.labels.values = lineChartXLabels
            lineChart.x.labels.color = UIColor.white
            lineChart.x.labels.font = UIFont.defaultFont(.light, size: 9.0)!
            
            lineChart.y.grid.visible = false
            lineChart.y.axis.visible = false
            lineChart.y.axis.inset = 30.0
            lineChart.y.labels.visible = true
            lineChart.y.labels.color = UIColor.white
            lineChart.y.labels.font = UIFont.defaultFont(.light, size: 9.0)!
            
            lineChart.dots.color = UIColor.red
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
    
    fileprivate func setupLineChartLabels() {
        
        let fontSize = min(view.bounds.size.width / 31, 15.0)
        let legendFont = UIFont.defaultFont(.bold, size: fontSize)
        let legendColor = UIColor.white
        
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
        
        bottomSubtitleLabel.font = UIFont.defaultFont(.light, size: 13.0)
        bottomSubtitleLabel.textColor = UIColor.white
        bottomSubtitleLabel.text = NSLocalizedString("Weekly data", comment: "Line chart bottom subtitle")
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupStatusViews()
        
        setupPieChart()
        
        setupCollectionView()
        
        bottomHorizontalLine.backgroundColor = UIColor.ftMidGray()
        bottomHorizontalLineHeight.constant = 0.5
        
        setupTopTitleLabels()
    }
    
    // MARK: - Actions
    
    @IBAction func addActivityButtonTouched(_ sender: AnyObject) {
        
        FTAnalytics.trackEvent(.NewActivityFromHome, data: nil)
        performSegue(withIdentifier: medicationsSegueId, sender: NSNumber(value: true as Bool))
    }

    // MARK: - Notifications
    
    fileprivate func manageForMenuNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.menuItemSelectedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTSlideMenuItemSelectedNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTSlideMenuItemSelectedNotificationName), object: nil)
        }
    }
    
    func menuItemSelectedNotificationReceived(_ notification: Notification) {
        
        if let index = notification.userInfo?["itemIndex"] as? Int {
            
            if let item = FTSlideMenuItem(rawValue: index) {
                
                switch item {
                case .profile: performSegue(withIdentifier: profileSegueId, sender: self)
                case .main: navigationController?.popToRootViewController(animated: true)
                case .workouts: performSegue(withIdentifier: medicationsSegueId, sender: self)
                case .tutorial: performSegue(withIdentifier: tutorialSegueId, sender: self)
                case .faq: openLink(FTFAQLink)
                case .terms: openLink(FTTermsAndConditionsLink)
                default: print("Implement menu for \(item)")
                }
            }
        }
    }
    
    fileprivate func manageForMedicationNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.medicationChangedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTMedicationSavedNotificationName), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.medicationChangedNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTMedicationDeletedNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTMedicationSavedNotificationName), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTMedicationDeletedNotificationName), object: nil)
        }
    }
    
    func medicationChangedNotificationReceived(_ notification: Notification) {
        
        fetchMedications()
    }
    
    fileprivate func manageForLoginNotification(_ signup: Bool) {
        
        if signup {
            NotificationCenter.default.addObserver(self, selector: #selector(self.loginNotificationReceived(_:)), name: NSNotification.Name(rawValue: FTSignedInNotificationName), object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FTSignedInNotificationName), object: nil)
        }
    }
    
    func loginNotificationReceived(_ notification: Notification) {
        
        fetchMedications()
    }
    
    func openLink(_ linkStr: String) {
        
        if let url = URL(string: linkStr) {
            
            if UIApplication.shared.canOpenURL(url) {
                
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == medicationsSegueId {
            
            if let addNewMedication = sender as? NSNumber {
                
                (segue.destination as! FTMedicationsViewController).shouldAddNewActivityOnShow = addNewMedication.boolValue
            }
        }
    }
    
    // MARK: - Pie Chart
    
    func numberOfSlices(in pieChart: XYPieChart!) -> UInt {
        
        return  UInt(activityValues.count)
    }
    
    func pieChart(_ pieChart: XYPieChart!, valueForSliceAt index: UInt) -> CGFloat {
        
        let activityType = ActivityType.allValues[Int(index)]
            
        if let data = activityValues[activityType] {
            
            return CGFloat(data.totalDuration)
        }
        
        return 0.0
    }
    
    func pieChart(_ pieChart: XYPieChart!, colorForSliceAt index: UInt) -> UIColor! {
        
        let activityType = ActivityType.allValues[Int(index)]
        
        return activityType.color()
    }
    
    func pieChart(_ pieChart: XYPieChart!, textForSliceAt index: UInt) -> String! {
        
        return ""
    }
    
    // MARK: - CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return activityValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: moodCellId, for: indexPath) as! FTActivityValueCell
        
        let activityType = ActivityType.allValues[indexPath.item]
        if let data = activityValues[activityType] {
            cell.setupCell(activityType, value: data.totalCount)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: max(collectionView.bounds.size.width / CGFloat(max(activityValues.count, 1)), 1.0), height: collectionView.bounds.size.height)
    }
    
    // MARK: - Data integration
    
    fileprivate func populatePieLabelsData() {
        
        let formatter = DateFormatter()
        let name = formatter.monthSymbols[currentMonth - 1]
        pieMonthLabel.text = name.uppercased()
        
        pieYearLabel.text = "\(currentYear)"
    }
    
    fileprivate func fetchMedications() {
        
        if status != .loading && FTDataManager.sharedInstance.currentUser != nil {
            
            status = .loading
            
            var nextMonth = currentMonth + 1
            var nextYear = currentYear
            if currentMonth > 12 {
                nextYear += 1
                nextMonth = 1
            }
            
            let calendar = Calendar.current
            
            var comps = DateComponents()
            
            comps.year = currentYear
            comps.month = currentMonth
            comps.day = 1
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            
            let startDate = calendar.date(from: comps)
            
            comps.year = nextYear
            comps.month = nextMonth
            comps.day = 1
            comps.hour = 23
            comps.minute = 59
            comps.second = 59
            
            let finishDate = calendar.date(from: comps)?.addingTimeInterval(-1 * 24 * 60 * 60)

            var query = "ownerId = '\(FTDataManager.sharedInstance.currentUser!.objectId!)'"
            
            query += " AND activity.startDate >= \(startDate!.timeIntervalSince1970 * 1000) AND activity.startDate <= \(finishDate!.timeIntervalSince1970 * 1000)"
            
            Medication.findObjects(query, order: ["created desc" as AnyObject], offset: 0, limit: 100) { (objects, error) in
                
                if objects != nil {
                    
                    let sortedMedications = (objects as! [Medication]).sorted(by: { (medication1, medication2) -> Bool in
                        if medication1.activity != nil && medication2.activity != nil {
                            if medication1.activity!.startDate != nil && medication2.activity!.startDate != nil {
                                return medication1.activity!.startDate!.compare(medication2.activity!.startDate!) == .orderedAscending
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
                    
                    let calendar = Calendar.current
                    
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
                                
                                day = (calendar as NSCalendar).component(.day, from: medication.activity!.startDate!)
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
                    
                    DispatchQueue.main.async(execute: {
                        
                        if objects != nil && objects!.count > 0 {
                            self.status = .normal
                        }
                        else {
                            self.status = .noActivities
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
                    self.status = .noActivities
                }
            }
        }
    }
}

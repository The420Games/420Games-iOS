//
//  FTTutorialSinglePageViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 16..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTTutorialSinglePageViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    private let pageTexts = [
        NSLocalizedString("BE ACTIVE AND HELP FORGING A NEW LOOK AT CANNABIS", comment: "Tutorial text page 1"),
        NSLocalizedString("SHOW OFF YOU ARE MOTIVATED AND LIVE AN ACTIVE LIFE", comment: "Tutorial text page 2"),
        NSLocalizedString("LOG YOUR ACTIVITIIES DURING MEDICATION AND SEE YOUR PERFORMANCE HERE", comment: "Tutorial text page 3")
    ]
    
    private let pageBackgrounds = [
        UIImage(named: "bg_tutorial-1"),
        UIImage(named: "bg_tutorial-2"),
        UIImage(named: "bg_tutorial-3")
    ]
    
    var pageIndex = 0
    
    //MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        setupUI()
        
        populateData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        FTAnalytics.trackEvent(.Tutorial, data: ["page": pageIndex])
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        textLabel.font = UIFont.defaultFont(.Bold, size: 19.0)
        textLabel.textColor = UIColor.ftLimeGreen()
    }
    
    // MARK: - Data integration
    
    private func populateData() {
        backgroundImageView.image = pageBackgrounds[pageIndex]
        textLabel.text = pageTexts[pageIndex]
    }

}

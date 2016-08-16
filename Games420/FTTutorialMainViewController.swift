//
//  FTTutorialMainViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 16..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

let FTTutorialSeenDefaultsKey = "TutorialFinished"

class FTTutorialMainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    
    private var pageViewController: UIPageViewController!
    
    private let numberOfPages = 3
    private var currentPageIndex = 0
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        persistTutorialSeenStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI Customizatons
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupPageViewController()
        
        setupPageControl()
    }
    
    private func setupPageViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstPage = loadPage(0)
        pageViewController.setViewControllers([firstPage], direction: .Forward, animated: true) { (finished) in
            //
        }
        pageViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.insertSubview(pageViewController.view, atIndex: 0)
    }
    
    private func setupPageControl() {
        
        pageControl.currentPageIndicatorTintColor = UIColor.ftLimeGreen()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPageIndex
    }
    
    // MARK: - Persistence
    
    private func persistTutorialSeenStatus() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(FTTutorialSeenDefaultsKey) as? Bool) != nil {
            //Tutorial seen already set
        } else {
            
            defaults.setBool(true, forKey: FTTutorialSeenDefaultsKey)
            defaults.synchronize()
        }
    }
    
    class func isTutorialSeen() ->Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let value = defaults.objectForKey(FTTutorialSeenDefaultsKey) as? NSNumber {
            return value.boolValue
        }
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTouched(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - PageViewController
    
    private func loadPage(index: Int) -> FTTutorialSinglePageViewController {
        
        let page = self.storyboard?.instantiateViewControllerWithIdentifier("FTTutorialSinglePageViewController") as! FTTutorialSinglePageViewController
        page.pageIndex =  index
        
        return page
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! FTTutorialSinglePageViewController).pageIndex
        
        if index < numberOfPages - 1 {
            
            index += 1
            
            let page = loadPage(index)
            
            currentPageIndex = index
            
            return page
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! FTTutorialSinglePageViewController).pageIndex
        
        if index > 0 {
            
            index -= 1
            
            let page = loadPage(index)
            
            currentPageIndex = index
            
            return page
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        if let page = pendingViewControllers.last as? FTTutorialSinglePageViewController {
            pageControl.currentPage = page.pageIndex
        }
    }

}

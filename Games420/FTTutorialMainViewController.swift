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
    
    fileprivate var pageViewController: UIPageViewController!
    
    fileprivate let numberOfPages = 3
    fileprivate var currentPageIndex = 0
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        persistTutorialSeenStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI Customizatons
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        setupPageViewController()
        
        setupPageControl()
    }
    
    fileprivate func setupPageViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstPage = loadPage(0)
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: true) { (finished) in
            //
        }
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(pageViewController.view, at: 0)
    }
    
    fileprivate func setupPageControl() {
        
        pageControl.currentPageIndicatorTintColor = UIColor.ftLimeGreen()
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
        
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPageIndex
    }
    
    // MARK: - Persistence
    
    fileprivate func persistTutorialSeenStatus() {
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: FTTutorialSeenDefaultsKey) as? Bool) != nil {
            //Tutorial seen already set
        } else {
            
            defaults.set(true, forKey: FTTutorialSeenDefaultsKey)
            defaults.synchronize()
        }
    }
    
    class func isTutorialSeen() ->Bool {
        
        let defaults = UserDefaults.standard
        
        if let value = defaults.object(forKey: FTTutorialSeenDefaultsKey) as? NSNumber {
            return value.boolValue
        }
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTouched(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - PageViewController
    
    fileprivate func loadPage(_ index: Int) -> FTTutorialSinglePageViewController {
        
        let page = self.storyboard?.instantiateViewController(withIdentifier: "FTTutorialSinglePageViewController") as! FTTutorialSinglePageViewController
        page.pageIndex =  index
        
        return page
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! FTTutorialSinglePageViewController).pageIndex
        
        if index < numberOfPages - 1 {
            
            index += 1
            
            let page = loadPage(index)
            
            currentPageIndex = index
            
            return page
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! FTTutorialSinglePageViewController).pageIndex
        
        if index > 0 {
            
            index -= 1
            
            let page = loadPage(index)
            
            currentPageIndex = index
            
            return page
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let page = pendingViewControllers.last as? FTTutorialSinglePageViewController {
            pageControl.currentPage = page.pageIndex
        }
    }

}

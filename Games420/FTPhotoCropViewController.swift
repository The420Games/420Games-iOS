//
//  FTPhotoCropViewController.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 09..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTPhotoCropViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    
    var originalPhoto: UIImage!
    
    var completionBlock: ((_ croppedPhoto: UIImage) -> ())?
    
    // MARK: - Controller lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        photoImageView.image = originalPhoto
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        setupOverlay()
        
        FTAnalytics.trackEvent(.EditProfilePhoto, data: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customizations
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.ftMainBackgroundColor()
        
        navigationItem.title = NSLocalizedString("Set photo", comment: "Set profile photo navigation title")
        
        setupScrollView()
        
        addDoneButton()
        
        navigationItem.addEmptyBackButton(self, action: #selector(self.backButtonTouched(_:)))
    }
    
    fileprivate func setupOverlay() {
        
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = overlayView.bounds.size.width / 2
    }
    
    fileprivate func setupScrollView() {
        
        photoScrollView.contentSize = originalPhoto.size
        photoScrollView.delegate = self
        photoScrollView.minimumZoomScale = 0.1
        photoScrollView.maximumZoomScale = 20.0
    }
    
    fileprivate func addDoneButton() {
        
        let item = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button title"), style: .done, target: self, action: #selector(self.doneButtonTouched(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    // MARK: - Actions
    
    func backButtonTouched(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func doneButtonTouched(_ sender: AnyObject) {
        
        let croppedPhoto = makeCroppedPhoto()
        
        completionBlock?(croppedPhoto)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Photo cropping
    
    fileprivate func makeCroppedPhoto() -> UIImage {
        
        let scale = UIScreen.main.scale
        
        overlayView.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let shot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        overlayView.isHidden = false
        
        let width = overlayView.bounds.size.width
        let height = overlayView.bounds.size.height
        
        let cropRect = CGRect(x: (overlayView.center.x - width / 2) * scale, y: (overlayView.center.y - height / 2) * scale, width: width * scale, height: height * scale)
        
        // Draw new image in current graphics context
        let imageRef = (shot?.cgImage)?.cropping(to: cropRect);
        
        // Create new cropped UIImage
        let croppedImage = UIImage(cgImage: imageRef!)
        
        return croppedImage
    }
    
    // MARK: - Scrollview delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return photoImageView
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

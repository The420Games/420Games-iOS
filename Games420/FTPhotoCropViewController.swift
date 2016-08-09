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
    
    var completionBlock: ((croppedPhoto: UIImage) -> ())?
    
    var overlayBounds: CGRect!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        photoImageView.image = originalPhoto
        setupScrollView()
        
        addDoneButton()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        overlayBounds = overlayView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customizations
    
    private func setupScrollView() {
        
        photoScrollView.contentSize = originalPhoto.size
        photoScrollView.delegate = self
        photoScrollView.minimumZoomScale = 0.1
        photoScrollView.maximumZoomScale = 20.0
    }
    
    private func addDoneButton() {
        
        let item = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button title"), style: .Done, target: self, action: #selector(self.doneButtonTouched(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    // MARK: - Actions
    
    func doneButtonTouched(sender: AnyObject) {
        
        let croppedPhoto = makeCroppedPhoto()
        
        completionBlock?(croppedPhoto: croppedPhoto)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Photo cropping
    
    private func makeCroppedPhoto() -> UIImage {
        
        let scale = UIScreen.mainScreen().scale
        
        overlayView.hidden = true
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        
        let shot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        overlayView.hidden = false
        
        let width = overlayView.bounds.size.width
        let height = overlayView.bounds.size.height
        
        let cropRect = CGRect(x: (overlayView.center.x - width / 2) * scale, y: (overlayView.center.y - height / 2) * scale, width: width * scale, height: height * scale)
        
        // Draw new image in current graphics context
        let imageRef = CGImageCreateWithImageInRect(shot.CGImage, cropRect);
        
        // Create new cropped UIImage
        let croppedImage = UIImage(CGImage: imageRef!)
        
        return croppedImage
    }
    
    // MARK: - Scrollview delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
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

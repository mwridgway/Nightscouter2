//
//  SiteViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 6/13/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import UIKit
import NightscouterKit
import ReactiveCocoa

class FormViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var formLabel: UILabel!
    @IBOutlet private weak var formDescription: UILabel!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var middleLayoutContraint: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    /*
    This value is either passed by ViewController in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new site.
    */
    var site: Site?
    
    var tintColorForButton: UIColor {
        set{
            nextButton.tintColor = tintColorForButton
        }
        get{
            return nextButton.tintColor
        }
    }
    
    private var currentOrientation: UIDeviceOrientation?
    private var validatedUrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing Site.
        if let site = site {
            navigationItem.title = site.url.host
            urlTextField.text   = site.url.absoluteString
            passwordTextField.text = site.apiSecret
        }
        
        urlTextField.delegate = self
        
        let urlStrings = urlTextField.rac_textSignal()
            .toSignalProducer()
            .map { text in text as! String }
            .throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
        
        let validationResults = urlStrings
            .flatMap(.Latest) { (query: String) -> SignalProducer<(NSData, NSURLResponse), NSError> in
                let cleanString = query.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
                
                if cleanString.isEmpty { return SignalProducer.empty }
                // Test that URL actually exists by sending a URL request that returns only the header response
                self.urlTextField.text = cleanString
                
                self.activityIndicator.startAnimating()
                do  {
                    
                    let url = try NSURL.validateUrl(cleanString)
                    let request = NSMutableURLRequest(URL: url)
                    request.HTTPMethod = "HEAD"
                    
                    return NSURLSession.sharedSession()
                        .rac_dataWithRequest(request)
                        .retry(2)
                        .flatMapError { error in
                            // print("Network error occurred: \(error)")
                            // FIXME: It seems like there is a better way to handle these side effects...
                            // Is there a way to alway pass a bool down to subscribers?
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.nextButton.enabled = false
                                self.activityIndicator.stopAnimating()
                            })
                            return SignalProducer.empty
                    }
                    
                } catch let error {
                    print("Error validating URL: \(error)")
                    // FIXME: It seems like there is a better way to handle these side effects...
                    // Is there a way to alway pass a bool down to subscribers?
                    self.nextButton.enabled = false
                    self.activityIndicator.stopAnimating()
                    return SignalProducer.empty
                }
                
            }
            .map { (data, URLResponse) -> String? in
                // URL Responded - Check Status Code
                // 200-399 = Valid Responses, 405 = Valid Response (Weird Response on some valid URLs)
                guard let urlResponse = URLResponse as? NSHTTPURLResponse where ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400) || urlResponse.statusCode == 405) else {
                    return nil
                }
                
                return urlResponse.URL?.absoluteString
            }
            .observeOn(UIScheduler())
        
        validationResults.startWithNext { results in
            print("Validation results: \(results)")
            self.validatedUrlString = results
            self.nextButton.enabled = (results != nil) ? true : false
            self.activityIndicator.stopAnimating()
            
        }
        
        let offset = 1.0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            // Do something
            self.urlTextField.becomeFirstResponder()
        })
        
        tintColorForButton = NightscouterAssetKit.darkNavColor
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        currentOrientation = UIDevice.currentDevice().orientation
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func createSite() {
        // Set the site to be passed to ViewController after the unwind segue.
        let urlString = validatedUrlString ?? ""
        
        if let url = NSURL(string: urlString) {
            
            if var siteOptional = site {
                siteOptional.url = url
                siteOptional.apiSecret = passwordTextField.text ?? ""
                site = siteOptional
            } else {
                site = Site(url: url, apiSecret: passwordTextField.text ?? "")
            }
            // Hide the keyboard
            urlTextField.resignFirstResponder()
        }
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.nextButton.enabled {
            // Hide the keyboard
            textField.resignFirstResponder()
            
            self.view.endEditing(true)
            
            performSegueWithIdentifier(SitesTableViewController.SegueIdentifier
                .UnwindToSiteList.rawValue, sender: nextButton)
        }
        
        return self.nextButton.enabled
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if nextButton === sender {
            createSite()
        }
    }
    
    // MARK: Actions
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        urlTextField.resignFirstResponder()
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Keyboard Notifications
    
    func observeKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationDuration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey])!.doubleValue
        
        let orientation = UIDevice.currentDevice().orientation
        let isPortrait = UIDeviceOrientationIsPortrait(orientation)
        let height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width
        
        self.middleLayoutContraint.constant = -(height * 0.1)
        
        if (self.currentOrientation != orientation) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        // let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationDuration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey])!.doubleValue
        
        self.middleLayoutContraint.constant = 0
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}


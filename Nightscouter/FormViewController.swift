//
//  SiteViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 6/13/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import UIKit
import NightscouterKit

protocol FormViewControllerDelegate {
    func formViewControllerDidCancel(viewController: FormViewController)
    func formViewControllerDidCreateSite(site: Site, viewController: FormViewController)
}

class FormViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var formLabel: UILabel!
    @IBOutlet private weak var formDescription: UILabel!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var middleLayoutContraint: NSLayoutConstraint!
//    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    var delegate: FormViewControllerDelegate?
    
    /*
    This value is either passed by ViewController in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new site.
    */
    var site: Site? {
        didSet{
            if let site = site {
                self.delegate?.formViewControllerDidCreateSite(site, viewController: self)
            }
        }
    }
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add notification observer for text field updates
        urlTextField.addTarget(self, action: "textFieldDidUpdate:", forControlEvents: UIControlEvents.EditingChanged)
        urlTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let site = site {
            navigationItem.title = site.url.host
            urlTextField.text   = site.url.absoluteString
            
            passwordTextField.text = site.apiSecret
        }
        
        checkValidSiteName()
        
        // Or you can do it the old way
        let offset = 2.0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            // Do something
            self.urlTextField.becomeFirstResponder()
        })
        
        nextButton.tintColor = tintColorForButton //NightscouterAssetKit.darkNavColor
        
        observeKeyboard()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        currentOrientation = UIDevice.currentDevice().orientation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func textFieldDidUpdate(textField: UITextField)
    {
        checkValidSiteName()
    }
    
    func checkValidSiteName() {
        // Remove Spaces
        
        urlTextField.text = urlTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        
        // Or you can do it the old way
        let offset = 0.5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            // Validate URL
            //self.activityIndicator.startAnimating()
            NSURL.validateUrl(self.urlTextField.text, completion: { (success, urlString, error) -> Void in
                print("validateURL Error: \(error)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success)
                    {
                        NSURL.ValidationQueue.queue.cancelAllOperations()
                        NSURL.ValidationQueue.task.cancel()
                        self.validatedUrlString = urlString!
                    }
                    else
                    {
                        self.validatedUrlString = nil
                    }
                    self.nextButton.enabled = success
                    
                    // self.activityIndicator.stopAnimating()
                })
            })
        })
        
    }
    
    func createSite() {
        // Set the site to be passed to ViewController after the unwind segue.
        let urlString = validatedUrlString ?? ""
        
        if let url = NSURL(string: urlString) {
            
            if var siteOptional = site {
                siteOptional.url = url
                site = siteOptional
            } else {
                //#warning TODO: Finish this code
                // site = Site(url: url, apiSecret: nil)
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
            //#warning TODO: Finish this code
            
            
            // performSegueWithIdentifier(Constants.SegueIdentifier.UnwindToSiteList.rawValue, sender: nextButton)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
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


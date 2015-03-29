//
//  HomeViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/25/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //@IBOutlet var fbLoginView : FBLoginView!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    let nextSegue = "ToMessagesSegue"
    let backSegue = "homeToLogin"
    
    var roomTarget : String = ""
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func searchButtonClicked() {
        // Send Search message
        
        searchButton.setTitle("Searching...", forState: .Normal)
        
        var spinner = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(spinner)
        spinner.startAnimating()
        
        searchButton.enabled = false
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.readyToChat = true
        
        delegate.socket?.sendInfo(delegate.fbProfile!)
        delegate.socket?.sendSearch(delegate.fbProfile!) { (roomTarget : String) in
            
            if delegate.readyToChat == true {
                self.roomTarget = roomTarget
                delegate.readyToChat = false
                delegate.inChat = true
                self.performSegueWithIdentifier(self.nextSegue, sender: nil)
            }
            
            // Reset searchButton
            self.searchButton.enabled = true
            spinner.stopAnimating()
            self.searchButton.setTitle("Search again", forState: .Normal)
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchButton.enabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("invoke: loginButton - should never be called here")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("invoke: loginButtonDidLogOut")
        self.performSegueWithIdentifier(backSegue, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nextSegue {
            let MessagesVC = segue.destinationViewController as MessagesViewController
            MessagesVC.roomTarget = self.roomTarget
        }
    }
    
    
    // UTIL Functions
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}

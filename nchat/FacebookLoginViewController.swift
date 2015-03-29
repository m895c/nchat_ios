//
//  FacebookLoginViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/25/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class FacebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    //@IBOutlet var fbLoginView : FBLoginView!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    let nextSegue = "ToMessagesSegue"
    
    var roomTarget : String = ""
    
    @IBOutlet weak var searchButton: UIButton!
    
    var socket : Socket?
    
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
        
        socket?.sendInfo(delegate.fbProfile!)
        socket?.sendSearch(delegate.fbProfile!) { (roomTarget : String) in
            
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
        
        self.searchButton.enabled = false
        
        self.socket = Socket()
        
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.delegate = self
        
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            // FBLoggedIn, segue to chat
            
            fetchFBProfile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func segueToMessagesView() {
        println("invoke: segueToMessagesView")
        self.performSegueWithIdentifier(nextSegue, sender: nil)
    }
    
    func fetchFBProfile() {
        println("invoke: fetchFBProfile")
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            let meRequest = FBSDKGraphRequest(graphPath: "me?fields=['gender','first_name','id','link']", parameters: nil)
            let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?redirect=false&width=400", parameters: nil)
                
            let conn = FBSDKGraphRequestConnection()
            
            conn.addRequest(meRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error == nil {
                    let infoDict = result as? NSDictionary
                    
                    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                    delegate.fbProfile = infoDict
                    
                    self.socket?.sendInfo(delegate.fbProfile!)
                    self.searchButton.enabled = true
                } else {
                    self.failedToConnectPopUp(error)
                }
            })
            
            conn.addRequest(pictureRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error == nil {
                    let photoDict = result as? NSDictionary
                    
                    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                    delegate.fbPicture = photoDict
                }
            })
            
            conn.start()
        }
    }
    
    func failedToConnectPopUp(error : NSError!) {
        println("Error occured fetching data\n error: \(error)")
        var alert = UIAlertController(title: "Error", message: "Failed to connect to the internet. Please close the app and try again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("invoke: loginButton\n result: \(result)")
        fetchFBProfile()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
       println("invoke: loginButtonDidLogOut")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nextSegue {
            let MessagesVC = segue.destinationViewController as MessagesViewController
            MessagesVC.socket = self.socket
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

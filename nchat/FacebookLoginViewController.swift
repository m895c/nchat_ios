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
    
    var fbProfile : NSDictionary?
    
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
        
        socket?.sendSearch(fbProfile!) { (roomTarget : String) in
            
            let delegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            if delegate.inChatConversation == false {
                self.roomTarget = roomTarget
                self.performSegueWithIdentifier(self.nextSegue, sender: nil)
                delegate.inChatConversation = true
            }
            
            // Reset searchButton
            self.searchButton.enabled = true
            spinner.stopAnimating()
            self.searchButton.setTitle("Search again", forState: .Normal)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.socket = Socket()
        
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.delegate = self
        
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            // FBLoggedIn, segue to chat
            
            fetchFBProfile()
        }
    }
    
    func segueToMessagesView() {
        println("invoke: segueToMessagesView")
        self.performSegueWithIdentifier(nextSegue, sender: nil)
    }
    
    func fetchFBProfile() {
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler(
                { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                    if error == nil {
                        self.fbProfile = result as? NSDictionary
                        println("invoke: fbGetProfile with data: \(self.fbProfile)")
                    } else {
                        println("Error occured fetching data")
                    }
                self.socket?.sendInfo(self.fbProfile!)
            })
        }
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("invoke: loginButton\n result: \(result)")
        fetchFBProfile()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
       println("invoke: loginButtonDidLogOut")
    }
    
    //func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
    //    // THIS IS CALLED soemtimes before loginViewFetchedUserInfo
    //    println("invoke: loginViewShowingLoggedInUser - performing segue")
    //    if (fbProfile != nil) {
    //    self.performSegueWithIdentifier(nextSegue, sender: nil)
    //    } else {
    //        println("No FB User definied")
    //    }
    //}
    //
    //func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
    //    println("invoke: loginViewFetchedUserInfo - setting FBUser")
    //    self.fbProfile = user
    //}
    //
    //func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
    //    println("User Logged Out")
    //}
    //
    //func loginView(loginView : FBLoginView!, handleError:NSError) {
    //    println("Error: \(handleError.localizedDescription)")
    //}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nextSegue {
            let MessagesVC = segue.destinationViewController as MessagesViewController
            MessagesVC.fbProfile = self.fbProfile
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

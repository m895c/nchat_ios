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
    
    let nextSegue = "loginToChatViewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.delegate = self
        
        
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            // FBLoggedIn, segue to chat
            
            
            fetchFBProfile() {
                self.segueToMessagesView()
            }
        }
        
        // FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        
        // Check if app is already logged in
        
        // Do any additional setup after loading the view.
    }
    
    func segueToMessagesView() {
        println("invoke: segueToMessagesView")
        self.performSegueWithIdentifier(nextSegue, sender: nil)
    }
    
    func fetchFBProfile(closure : () -> ()) {
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler(
                { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                    println("invoke: fbGetProfile callback")
                    if error == nil {
                        self.fbProfile = result as? NSDictionary
                    } else {
                        println("Error occured fetching data")
                    }
                closure()
            })
        }
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("invoke: loginButton\n result: \(result)")
        segueToMessagesView() }
    
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
            let StartChatVC = segue.destinationViewController as StartChatViewController
            StartChatVC.fbProfile = self.fbProfile
            
        }
    }
}

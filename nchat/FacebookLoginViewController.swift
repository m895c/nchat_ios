//
//  FacebookLoginViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/25/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class FacebookLoginViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet var fbLoginView : FBLoginView!
    
    var fbUser : FBGraphUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]

        
        // Check if app is already logged in
        
        // Do any additional setup after loading the view.
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        // THIS IS CALLED soemtimes before loginViewFetchedUserInfo
        println("invoke: loginViewShowingLoggedInUser - performing segue")
        if (fbUser != nil) {
        self.performSegueWithIdentifier("loginToChatViewSegue", sender: nil)
        } else {
            println("No FB User definied")
        }
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        println("invoke: loginViewFetchedUserInfo - setting FBUser")
        self.fbUser = user
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginToChatViewSegue" {
            let MessagesVC = segue.destinationViewController as MessagesViewController
            MessagesVC.fbUser = self.fbUser
            
        }
    }
}

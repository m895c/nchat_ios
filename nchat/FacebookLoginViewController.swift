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
        println("Calling loginViewShowingLoggedInUser")
        self.performSegueWithIdentifier("loginToChatViewSegue", sender: nil)
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        println("Calling loginViewFetchedUserInfo")
        println("storing the fbUser data")
        self.fbUser = user
        println("fetching stored fbUser data: contains \(self.fbUser)")
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

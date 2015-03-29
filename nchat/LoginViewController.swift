//
//  LoginViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/29/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    let nextSegue = "loginToHome"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIGraphicsBeginImageContext(self.view.frame.size)
        //UIImage(named: "ManHat")?.drawInRect(self.view.bounds)
        //
        //var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        //
        //UIGraphicsEndImageContext()
        //self.view.backgroundColor = UIColor(patternImage: image)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.delegate = self
        
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            // FBLoggedIn, segue to chat
            fetchFBProfile()
        }
        // show we're loading your data
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("invoke: loginButton\n result: \(result)")
        fetchFBProfile()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("invoke: loginButtonDidLogOut - should never be called here")
    }
    
    func fetchFBProfile() {
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
                    
                    delegate.socket?.sendInfo(delegate.fbProfile!)
                    
                    self.performSegueWithIdentifier(self.nextSegue, sender: nil)
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

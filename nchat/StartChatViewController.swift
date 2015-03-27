//
//  StartChatViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/27/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class StartChatViewController: UIViewController {
    
    var fbProfile : NSDictionary?
    
    let nextSegue = "startChatToMessagesSegue"
    
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
            self.roomTarget = roomTarget
            self.performSegueWithIdentifier(self.nextSegue, sender: nil)
        }
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.socket = Socket()
        
        delay(0.5) {
            self.socket?.sendInfo(self.fbProfile!)
            // HACK to return optional nil
            var s : String? = nil
        }
        // Do any additional setup after loading the view.
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

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

}

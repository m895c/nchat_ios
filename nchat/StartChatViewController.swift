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

    var socket : Socket?
    
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
        }
    }

}

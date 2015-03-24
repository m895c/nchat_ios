//
//  ViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/23/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var socket : SIOSocket?

    @IBOutlet weak var messages: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messages.text = ""
        
        
        
        SIOSocket.socketWithHost("http://localhost:3000") { (socket: SIOSocket!) in
            self.socket = socket
            socket.on("chat message", callback: { (args: [AnyObject]!)  in
                let message : AnyObject = args[0]
                switch message {
                case is NSString:
                    let message_text = message as String
                    println(message_text)
                    self.messages.text = (self.messages.text! + "\n" + message_text)
                default:
                    println(args[0])
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


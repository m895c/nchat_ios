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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SIOSocket.socketWithHost("http://192.168.12.200:3000") { (socket: SIOSocket!) in
            self.socket = socket
            socket.on("chat message", callback: { (args:[AnyObject]!)  in
                println(args)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


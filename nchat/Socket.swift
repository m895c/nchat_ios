//
//  Socket.swift
//  nchat
//
//  Created by Evan Carmi on 3/24/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import Foundation

class Socket {
    var socket : SIOSocket?
    
    let socketHost  = "http://localhost:3000"
    
    init(newMessage : (String) -> () ) {
        SIOSocket.socketWithHost("http://localhost:3000") { (socket: SIOSocket!) in
            self.socket = socket
            
            socket.on("chat message", callback: { (args: [AnyObject]!)  in
                let message : AnyObject = args[0]
                
                switch message {
                case is NSString:
                    let message_text = message as String
                    newMessage(message_text)
                default:
                    println(args[0])
                }
            })
        }
    }
}
//
//  Socket.swift
//  nchat
//
//  Created by Evan Carmi on 3/24/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import Foundation

class Socket {
    let socketHost  = "localhost:3000"
    let socket = SocketIOClient(socketURL: "localhost:3000")
    
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let messageDict = ["text": text, "senderId": senderId ]
        socket.emit("chat message", messageDict)
    }
    
    init(newMessage : (String, String) -> () ) {
        socket.on("chat message") {[weak self] data, ack in
            if let dict = data?[0] as? NSDictionary {
                let message = dict["text"] as String
                let senderId = dict["senderId"] as String
                newMessage(message, senderId)
            }
        }
        socket.connect()
    }
}
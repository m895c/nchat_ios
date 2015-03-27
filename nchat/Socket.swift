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
    

    func sendInfo(info : FBGraphUser) -> () {
        println("invoke Socket: sendInfo")
        let infoDict : [String : String] = [
            "name": info.name!,
            "age": "27",//fbUser?.age?
            "sex": "1",
            "target": "0"
        ]
        println("Here is called: emiting info \(infoDict)")
        socket.emit("info", infoDict)
    }
    
    func addChatMessageHandler(forwardMessage : (String, String) -> () ) {
        println("invoke Socket: addChatMessageHandler")
        socket.on("chat message") {[weak self] data, ack in
            if let dict = data?[0] as? NSDictionary {
                let message = dict["text"] as String
                let senderId = dict["senderId"] as String
                forwardMessage(message, senderId)
            }
        }
    }
    
    init() {
        println("invoke Socket: init()")
        socket.connect()
    }
}
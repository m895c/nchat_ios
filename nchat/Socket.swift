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
    
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!, roomTarget: String) {
        let messageDict = ["text": text, "senderId": senderId, "roomtgt": roomTarget ]
        socket.emit("chat message", messageDict)
    }
    

    func sendSearch(info : NSDictionary, onMatchHandler: (String) -> ()) -> () {
        addMatchHandler(onMatchHandler)
        socket.emit("search", extractFbInfo(info))
    }
    
    func addMatchHandler(handler: (String) -> ()) {
        socket.on("matched", { [weak self] data, ack in
            let roomTarget = data?[0] as? String
            println(roomTarget)
            handler(roomTarget!)
        })
    }
    
    func extractFbInfo(info: NSDictionary) -> Dictionary<String,String> {
        
        let name = info["name"]! as String
        let age = "27"
        let sex = "1"//info["gender"]! as String
        let target = "0"//"!\(sex)"
        let token = info["id"]! as String
        
        return [
            "name": name,
            "age": age,
            "sex": sex,
            "target": target,
            "token": token
        ]
    }
    
    func sendInfo(info : NSDictionary) -> () {
        socket.emit("info", extractFbInfo(info))
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
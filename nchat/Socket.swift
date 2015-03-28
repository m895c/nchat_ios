//
//  Socket.swift
//  nchat
//
//  Created by Evan Carmi on 3/24/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import Foundation

class Socket {
    let socket = SocketIOClient(socketURL: "45.33.12.6")
    
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
        
        var sex = ""
        var target = ""
        let age = "27"
        
        let gender = info["gender"]! as String
        let name = info["name"]! as String
        let token = info["id"]! as String
        
        
        switch gender {
            case "male": sex = "1"
            case "female": sex = "0"
            default: sex = "1"
        }
        
        if sex == "1" {
            target = "0"
        } else {
            target = "1"
        }
    
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
    
    func addTimeUpHandler(callback : () -> ()) ->() {
        socket.on("timeUp") { [weak self] data, ack in
            println("timeUp message received")
            callback()
        }
    }
    
    func addChatMessageHandler(forwardMessage : (String, String, String) -> () ) {
        println("invoke Socket: addChatMessageHandler")
        socket.on("chat message") {[weak self] data, ack in
            if let dict = data?[0] as? NSDictionary {
                println("received chat message with: \(dict)")
                let message = dict["text"] as String
                let senderId = dict["senderId"] as String
                forwardMessage(message, senderId, senderId)
            }
        }
    }
    
    init() {
        println("invoke Socket: init()")
        socket.connect()
    }
}
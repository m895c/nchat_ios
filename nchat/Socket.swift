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
    
    func sendReveal(roomTarget: String, info: NSDictionary) {
        // TODO: only send necessary fields
        var revealInfo = extractFbInfo(info)
        revealInfo["roomtgt"] = roomTarget
        
        // add roomtgt
        socket.emit("reveal", revealInfo)
    }
    
    func addRevealHandler(callback : (NSDictionary) -> ()) {
        socket.on("reveal") {[weak self] data, ack in
            if let dict = data?[0] as? NSDictionary {
                callback(dict)
            }
        }
    }
    
    func sendInfo(info : NSDictionary) -> () {
        let fbInfo = extractFbInfo(info)
        socket.emit("info", fbInfo)
    }
    
    func addMatchHandler(handler: (String) -> ()) {
        socket.on("matched", { [weak self] data, ack in
            let roomTarget = data?[0] as? String
            handler(roomTarget!)
        })
        socket.on("nomatch", { [weak self] data, ack in
            println("nomatch received!")
        })
    }
    
    
    func extractFbInfo(info: NSDictionary) -> Dictionary<String,String> {
        
        var sex = ""
        var target = ""
        let age = "27"
        
        let gender = info["gender"]! as String
        let link = info["link"]! as String
        let name = info["first_name"]! as String
        let token = info["id"]! as String
        
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        var picture_url = ""
        if let pic_data: AnyObject = delegate.fbPicture?["data"] {
            picture_url = pic_data["url"]?! as String
        }
        
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
            "link": link,
            "target": target,
            "picture_url": picture_url,
            "token": token
        ]
    }
    
    
    func addTimeUpHandler(callback : () -> ()) ->() {
        socket.on("timeUp") { [weak self] data, ack in
            callback()
        }
    }
    
    func addChatMessageHandler(forwardMessage : (String, String, String) -> () ) {
        socket.on("chat message") {[weak self] data, ack in
            if let dict = data?[0] as? NSDictionary {
                let message = dict["text"] as String
                let senderId = dict["senderId"] as String
                forwardMessage(message, senderId, senderId)
            }
        }
    }
    
    func disconnect() {
        socket.close(fast: false)
    }
    
    init() {
        socket.connect()
    }
}
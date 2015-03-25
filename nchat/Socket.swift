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
    
    func sendMessage(message : String) {
        socket.emit("chat message", message)
    }
    
    init(newMessage : (String) -> () ) {
        socket.on("chat message") {[weak self] data, ack in
            if let name = data?[0] as? String {
                newMessage(name)
                println(data)
            }
        }
        socket.connect()
    }
}
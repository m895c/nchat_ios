//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    var text_: String
    var senderId_: String
    var senderDisplayName_: String
    var date_: NSDate
    var imageUrl_: String?
    
    convenience init(text: String?, senderId: String, senderDisplayName: String) {
        self.init(text: text, senderId: senderId, senderDisplayName: senderDisplayName, imageUrl: nil)
    }
    
    init(text: String?, senderId: String?, senderDisplayName: String?, imageUrl: String?) {
        self.text_ = text!
        self.senderId_ = senderId!
        self.senderDisplayName_ = senderDisplayName!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
    }
    
    
    func text() -> String! {
        return text_
    }
    
    func senderId() -> String! {
        return senderId_
    }
    func senderDisplayName() -> String! {
        return senderDisplayName_
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func imageUrl() -> String? {
        return imageUrl_
    }
    
    
    func messageHash() -> UInt {
        return UInt (arc4random_uniform(999999999) )
    }
    
    func isMediaMessage() -> Bool {
        return false
    }
}
//
//  ViewController.swift
//  nchat
//
//  Created by Evan Carmi on 3/23/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import UIKit
import Foundation

class MessagesViewController: JSQMessagesViewController {
    
    var socket : Socket?
    var fbUser : FBGraphUser?
    
    var messages = [Message]()
    
    func receiveMessage(message : String, senderId: String) {
        let message = Message(text: message, senderId: senderId)
        self.messages.append(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.finishReceivingMessageAnimated(true)
        })
    }
    
    func senderId() -> String {
        if let id = fbUser?.objectForKey("id") as? NSString {
            return id
        } else {
            println("id was nil for fbUser with: \(fbUser)")
            return "11359"
        }
    }
    
    func senderDisplayName() -> String {
        return fbUser?.objectForKey("name") as NSString
    }
    
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //let message = Message(text: text, senderName: senderDisplayName)
        //self.messages.append(message)
        
        socket!.sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // messageInput.delegate = self
        
        //starting messages
        
        self.socket = Socket(receiveMessage)
        
        let automaticallyScrollsToMostRecentMessage = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ACTIONS
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId() == senderId() {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
        
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId() == senderId() {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        }
        
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        let diameter = UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width)
        
        let rgbValue = message.messageHash()
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let name = message.senderDisplayName()
        let nameLength = countElements(name)
        
        let initials : String? = name.substringToIndex(advance(name.startIndex, min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        return userImage
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId() == senderId() {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId() == message.senderId() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}


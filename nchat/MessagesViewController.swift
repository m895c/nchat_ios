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
    
    let countDownTime : NSTimeInterval = 120

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var roomTarget : String = ""
    
    var messages = [Message]()
    
    func receiveMessage(message : String, senderId: String, senderDisplayName: String) {
        let message = Message(text: message, senderId: senderId, senderDisplayName: senderDisplayName)
        displayNewMessage(message)
    }
    
    func displayNewMessage(message : Message) {
        self.messages.append(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.finishReceivingMessageAnimated(true)
        })
    }
    
    func senderId() -> String {
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let fbID = delegate.fbProfile?["id"]! as NSString
        
        // THIS IS BAD: We don't want other clients to actually see this info
        return fbID.substringWithRange(NSRange(location: 0, length: 10))
    }
    
    func senderDisplayName() -> String {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let name = delegate.fbProfile?["first_name"]! as NSString
        let firstInitial = name.substringWithRange(NSRange(location: 0, length: 1))
        return firstInitial
    }
    
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        receiveMessage(text, senderId: senderId, senderDisplayName: senderDisplayName)
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.socket?.sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date, roomTarget: roomTarget)
    }
        
    func setupSocket() {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.socket?.addChatMessageHandler(self.receiveMessage)
        
        delegate.socket?.addRevealHandler() { (revealDict : NSDictionary) in
            let picture_url = revealDict["picture_url"]! as String
            let name = revealDict["name"]! as String
            let token = revealDict["token"]! as String
            let link = revealDict["link"]! as String
            
            let url = NSURL(string: picture_url)
            
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            let image = UIImage(data: data!)
            
            let m1 = Message(text: "\(name) revealed themselves", senderId: token, senderDisplayName: token)
            let m2 = Message(text: "", senderId: token, senderDisplayName: token)
            let m3 = Message(text: "Click here to visit their Facebook: \(link)", senderId: token, senderDisplayName: token)
            
            var photoItem = JSQPhotoMediaItem(image: image)
            photoItem.appliesMediaViewMaskAsOutgoing = false
            
            m2.media_ = photoItem
            
            self.displayNewMessage(m1)
            self.displayNewMessage(m2)
            self.displayNewMessage(m3)
        }
        
        
    }
    
    func timeUp() {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        if delegate.inChat == true {
            let alertController = UIAlertController(title: "Time Up", message:
                "The clock has ran out.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { alert in
                self.navigationController?.popViewControllerAnimated(true)
                ()
            }))
            
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // messageInput.delegate = self
        
        //starting messages
        
        setupSocket()
        
        customizeView()
    }
    
    func customizeView() {
        
        // Make avatars dissapear
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    
        let automaticallyScrollsToMostRecentMessage = true
        
        // hide accessory button
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        
        self.navigationItem.titleView = createCountDownLabel()
        
        var revealButton = UIBarButtonItem(title: "Reveal Yourself", style: .Done, target: self, action:"revealButtonPressed")
        self.navigationItem.rightBarButtonItem = revealButton
        
        self.navigationItem.backBarButtonItem?.title = "Leave Chat"
    }
    
    func createCountDownLabel() -> UILabel {
        // Add countdown timer
        var label = UILabel(frame: CGRectMake(0, 0, 50, 50))
        
        let timer = MZTimerLabel(label: label, andTimerType:MZTimerLabelTypeTimer)
        timer.timeFormat = "m:ss"
        timer.setCountDownTime(countDownTime)
        
        timer.startWithEndingBlock { (time: NSTimeInterval) -> Void in
            self.timeUp()
        }
        timer.start()
        
        return label
    }
    
    
    func revealButtonPressed() {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.socket?.sendReveal(roomTarget, info: delegate.fbProfile!)
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.inChat = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ACTIONS
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if !message.isMediaMessage() {
            if message.senderId() == senderId() {
                cell.textView.textColor = UIColor.blackColor()
            } else {
                cell.textView.textColor = UIColor.whiteColor()
            }
            
            let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
            cell.textView.linkTextAttributes = attributes
        }
        
        
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
        
        return nil //userImage
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


//
//  ChatViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var currentUserLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var messagesScrollView: UIScrollView!
    
    let chat = Chat()
    var chatID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase.chatVC = self
        
        currentUserLabel.text = currentUser
        chat.prepareChatVCData(controller: self, chatID: chatID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessage(notification:)), name: .newMessage, object: nil)
    }
    
    @objc func newMessage(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            let snapshot = notificationData as! DataSnapshot
            
            if snapshot.hasChildren() {
                let message = snapshot.value as! NSDictionary
                if let sender = message["sender"], let message = message["message"] {
                    chat.addMessageToScrollView(controller: self, sender: String(describing: sender), message: String(describing: message))
                }
            }

        }
    }

    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        if let sender = currentUserLabel.text, let message = messageTextField.text {
            firebase.setMessage(sender: sender, message: message, chatID: chatID)
            chat.addMessageToScrollView(controller: self, sender: sender, message: message)
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        firebase.logout()
    }
    
}


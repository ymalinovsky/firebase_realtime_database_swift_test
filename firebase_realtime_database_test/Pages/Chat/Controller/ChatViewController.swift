//
//  ChatViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var currentUserLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var messagesScrollView: UIScrollView!
    
    let firebase = Firebase()
    let chat = Chat()
    var chatID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase.chatVC = self
        
        currentUserLabel.text = currentUser
        
        firebase.addNewMessageObserver()
    }

    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        if let sender = currentUserLabel.text, let message = messageTextField.text {
            firebase.setMessage(sender: sender, message: message, chatID: 1)
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        firebase.logout()
    }
    
}


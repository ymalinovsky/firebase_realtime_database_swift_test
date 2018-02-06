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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase.chatVC = self
        
        currentUserLabel.text = currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firebase.getData()
    }

    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        if let sender = currentUserLabel.text, let message = messageTextField.text {
            firebase.setData(sender: sender, message: message)
            
            chat.addMessageToScrollView(controller: self, sender: sender, message: message)
            
            if messagesScrollView.contentSize.height > messagesScrollView.frame.size.height {
                let bottomOffset = CGPoint(x: 0, y: messagesScrollView.contentSize.height - messagesScrollView.bounds.size.height)
                messagesScrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        firebase.logout()
    }
    
}


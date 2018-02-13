//
//  ChatsAlertController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 13.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class ChatsAlertController: UIAlertController {

    var chatsVC: ChatsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(presentAssignChatToUserOnChatsAlertController), name: .presentAssignChatToUserOnChatsAlertController, object: nil)
    }
    
    @objc func presentAssignChatToUserOnChatsAlertController(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            let createdChatData = notificationData as! [String: String]
            
            let chatID = Int(createdChatData["chatID"]!)!
            let title = createdChatData["title"]!
            let owner = createdChatData["owner"]!
            
            dismiss(animated: false) {
                self.chatsVC.helper.presentAssignChatToUserViewController(controller: self.chatsVC, chatID: chatID, title: title, owner: owner)
            }
        }
    }
}

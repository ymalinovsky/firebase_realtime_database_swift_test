//
//  Chats.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 12.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import Foundation
import UIKit

class Chats {
    func presentAssignChatToUserViewController(controller: ChatsViewController, chatID: Int, title: String, owner: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assignChatToUserVC = storyboard.instantiateViewController(withIdentifier: "assignChatToUserViewController") as! AssignChatToUserViewController
        
        assignChatToUserVC.chatID = chatID
        assignChatToUserVC.chatTitle = title
        assignChatToUserVC.chatOwner = owner
        assignChatToUserVC.chatsVC = controller
        
        controller.present(assignChatToUserVC, animated: true)
    }
}

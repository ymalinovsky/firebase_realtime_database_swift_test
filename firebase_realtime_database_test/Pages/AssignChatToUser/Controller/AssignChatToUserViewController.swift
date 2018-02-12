//
//  AssignChatToUserViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 09.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class AssignChatToUserViewController: UIViewController {

    var chatID: Int!
    var chatTitle: String!
    var chatOwner: String!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let owner = chatOwner, let title = chatTitle {
            titleLabel.text = "User \"\(owner)\" init chat \"\(title)\".\n\n\nAre you agree to join?"
        }
    }

    @IBAction func yesButtonAction(_ sender: UIButton) {
        firebase.addNewChatToUser(userID: currentUser, chatID: chatID, status: true)
        dismiss(animated: true)
    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {
        firebase.addNewChatToUser(userID: currentUser, chatID: chatID, status: false)
        dismiss(animated: true)
    }
    
}

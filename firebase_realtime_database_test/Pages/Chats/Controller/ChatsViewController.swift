//
//  ChatsViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 06.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let chatIDs = [1, 2]
    var newMessageChatIDs = [Int]()
    
    let chatCellIdentifier = "chatsCell"
    let chatSegueIdentifier = "chatSegue"
    
    var selectedIndexRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        for chatID in chatIDs {
            firebase.newMessageObserver(chatID: chatID)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(newMessage), name: .newMessage, object: nil)
    }

    @objc func newMessage(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            for notification in notificationData as! [Int: DataSnapshot] {
                let chatID = notification.key
                
                if !newMessageChatIDs.contains(where: {$0 == chatID}) {
                    newMessageChatIDs.append(chatID)
                    tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case chatSegueIdentifier:
            let chatVC = segue.destination as! ChatViewController
            chatVC.chatID = chatIDs[selectedIndexRow]
        default:
            print("Unpredicted segue identifier.")
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCellIdentifier)!
        
        let chatID = chatIDs[indexPath.row]
        
        cell.textLabel?.text = String(chatID)
        
        if newMessageChatIDs.contains(where: {$0 == chatID}) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatID = chatIDs[indexPath.row]
        newMessageChatIDs = newMessageChatIDs.filter() { $0 != chatID }
        
        selectedIndexRow = indexPath.row
        performSegue(withIdentifier: chatSegueIdentifier, sender: self)
    }
}

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
    
    var newMessageChatIDs = [Int]()
    
    let chatCellIdentifier = "chatsCell"
    let chatSegueIdentifier = "chatSegue"
    
    var selectedIndexRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
//        firebase.getAvailableCurrentUserChatList(userID: currentUser)
        firebase.newChatObserver(userID: currentUser)

        NotificationCenter.default.addObserver(self, selector: #selector(newMessage), name: .newMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fromChatVCtoChatsVC), name: .fromChatVCtoChatsVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newChatWasCreated), name: .newChatWasCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chatsVCTableViewMustBeReload), name: .chatsVCTableViewMustBeReload, object: nil)
    }

    @objc func newMessage(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            for notification in notificationData as! [Int: DataSnapshot] {
                let chatID = notification.key
                
                if !newMessageChatIDs.contains(where: { $0 == chatID }) {
                    newMessageChatIDs.append(chatID)
                    tableView.reloadData()
                }
            }
        }
    }
    
    @objc func fromChatVCtoChatsVC(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            let prevChatID = notificationData as! Int
            newMessageChatIDs = newMessageChatIDs.filter() { $0 != prevChatID }
        }
    }
    
    @objc func newChatWasCreated(notification: NSNotification) {
        if let notificationData = notification.userInfo?.first?.value {
            let createdChatData = notificationData as! [String: Any]
            
            let chatID = createdChatData["chatID"] as! Int
            let title = createdChatData["title"] as! String
            let owner = createdChatData["owner"] as! String
            
            if owner == currentUser {
                firebase.addNewChatToUser(userID: owner, chatID: chatID, status: true)
            } else {
                firebase.addNewChatToUser(userID: owner, chatID: chatID, status: false)
            }
        }
    }
    
    @objc func chatsVCTableViewMustBeReload(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func addNewChatButtonAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add new chat?", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textfield: UITextField) in
            textfield.placeholder = "Title"
        }
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            if let title = alertController.textFields?.first?.text {
                if !title.isEmpty {
                    firebase.addNewChat(title: title)
                } else {
                    let alertController = UIAlertController(title: "Chat title can't be empty.", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        alertController.modalPresentationStyle = .popover
                        self.present(alertController, animated: true, completion: nil)
                        
                        if let popoverPresentationController = alertController.popoverPresentationController {
                            popoverPresentationController.barButtonItem = sender
                        }
                    } else {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
                
            }
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.modalPresentationStyle = .popover
            present(alertController, animated: true, completion: nil)
            
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.barButtonItem = sender
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case chatSegueIdentifier:
            let chatVC = segue.destination as! ChatViewController
            chatVC.chatID = selectedIndexRow
        default:
            print("Unpredicted segue identifier.")
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCellIdentifier)!
        
        let chatID = availableChats[indexPath.row].first?.key
        
        let chatTitle = availableChats[indexPath.row].first?.value
        
        cell.textLabel?.text = chatTitle
        
        if newMessageChatIDs.contains(where: { $0 == chatID }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatID = availableChats[indexPath.row].first?.key
        
        newMessageChatIDs = newMessageChatIDs.filter() { $0 != chatID }
        
        selectedIndexRow = chatID
        performSegue(withIdentifier: chatSegueIdentifier, sender: self)
    }
}

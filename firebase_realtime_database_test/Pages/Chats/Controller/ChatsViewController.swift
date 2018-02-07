//
//  ChatsViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 06.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let chatIDs = [1, 2]
    
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
        
        cell.textLabel?.text = String(chatIDs[indexPath.row])
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexRow = indexPath.row
        performSegue(withIdentifier: chatSegueIdentifier, sender: self)
    }
}

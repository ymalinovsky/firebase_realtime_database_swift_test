//
//  Firebase.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import Foundation
import Firebase

class Firebase {
    var loginVC: LoginViewController!
    var signInVC: SignInViewController!
    var chatVC: ChatViewController!

    func emailRegistration(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatsNC = storyboard.instantiateViewController(withIdentifier: "chatsNavigationController")
                currentUser = email
                self.addNewMessageObserver()
                
                self.signInVC.present(chatsNC, animated: true)
            }
        })
    }
    
    func emailLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatsNC = storyboard.instantiateViewController(withIdentifier: "chatsNavigationController")
                currentUser = email
                self.addNewMessageObserver()
                
                self.loginVC.present(chatsNC, animated: true)
            }
        })
    }
    
    func loginAnonymous() {
        Auth.auth().createUser(withEmail: App.testUsername, password: App.testPassword, completion: { (user, error) in
            self.emailLogin(email: App.testUsername, password: App.testPassword)
        })
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homepageNC = storyboard.instantiateViewController(withIdentifier: "homepageNavigationController")
            currentUser = String()
            
            self.chatVC.present(homepageNC, animated: true)
        }
        catch {
            print(error)
        }
    }
    
    func setMessage(sender: String, message: String, chatID: Int) {
        let messagesDB = Database.database().reference().child(String(chatID)).child("messages")
        
        let messageDictionary : NSDictionary = ["sender" : sender, "message" : message]
        
        messagesDB.child(String(describing: Int(Date().timeIntervalSinceReferenceDate))).setValue(messageDictionary) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func addNewMessageObserver() {
        let messageDB = Database.database().reference()
        
        messageDB.observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                let chatData = snapshot.value as! NSDictionary
                let messagesData = chatData["messages"] as! NSDictionary
                
                for messageData in messagesData {
                    let message = messageData.value as! NSDictionary
                    if let sender = message["sender"], let message = message["message"] {
                        if let chatID = Int(snapshot.key) {
                            if chatsData != nil {
                                if var chatMassages = chatsData[chatID] {
                                    let massage = Massage(sender: String(describing: sender), message: String(describing: message))
                                    chatMassages.append(massage)
                                    
                                    chatsData[chatID] = chatMassages
                                } else {
                                    chatsData = [chatID: [Massage(sender: String(describing: sender), message: String(describing: message))]]
                                }
                            } else {
                                chatsData = [chatID: [Massage(sender: String(describing: sender), message: String(describing: message))]]
                            }
                        }
                    }
                }
                
//                if let message = messageData["message"], let sender = messageData["sender"] {
//                    self.chatVC.chat.addMessageToScrollView(controller: self.chatVC, sender: sender as! String, message: message as! String)
//
//                    if self.chatVC.messagesScrollView.contentSize.height > self.chatVC.messagesScrollView.frame.size.height {
//                        let bottomOffset = CGPoint(x: 0, y: self.chatVC.messagesScrollView.contentSize.height - self.chatVC.messagesScrollView.bounds.size.height)
//                        self.chatVC.messagesScrollView.setContentOffset(bottomOffset, animated: true)
//                    }
//                }
            }
        })
    }
}

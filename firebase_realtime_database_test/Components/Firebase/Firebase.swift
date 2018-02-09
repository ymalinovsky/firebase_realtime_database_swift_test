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
                self.createNewUserDBField(userID: email)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatsNC = storyboard.instantiateViewController(withIdentifier: "chatsNavigationController")
                currentUser = email
                
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
                
                self.loginVC.present(chatsNC, animated: true)
            }
        })
    }
    
    func loginAnonymous() {
        Auth.auth().createUser(withEmail: App.testUsername, password: App.testPassword, completion: { (user, error) in
            self.createNewUserDBField(userID: App.testUsername)
            self.emailLogin(email: App.testUsername, password: App.testPassword)
        })
    }
    
    func createNewUserDBField(userID: String) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!)
        
        userDB.child("id").setValue(userID) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func addNewChatToUser(userID: String, chatID: Int, status: Bool) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!).child("chats")
        
        userDB.child(String(describing: chatID)).setValue(status) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func addNewChatObserverSingleEvent() {
        let chatsDB = Database.database().reference().child("chats")
        
        chatsDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let chats = snapshot.children.allObjects
            
            let chatID = chats.count + 1
            let title = "TEST = \(chatID)"
            
            self.createNewChatDBField(chatID: chatID, title: title)
        })
    }
    
    func createNewChatDBField(chatID: Int, title: String) {
        let chatsDB = Database.database().reference().child("chats").child(String(chatID))
        
        chatsDB.child("title").setValue(title) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            NotificationCenter.default.post(name: .newChatWasCreated, object: nil, userInfo: [chatID: ["chatID": chatID, "title": title, "owner": currentUser]])
        }
    }
    
    func getAvailableCurrentUserChatList(userID: String) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!)
        
        userDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let chats = snapshot.value as! NSDictionary
            
            for chatsData in chats.dropLast() {
                let chatData = chatsData.value as! NSArray
                
                var chatID = 0
                for chat in chatData {
                    let status = chat as? Bool
                    
                    if status == true {
                        let chatsDB = Database.database().reference().child("chats").child(String(describing: chatID))
                        chatsDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                            let chatData = snapshot.value as! NSDictionary
                            
                            for chat in chatData {
                                if String(describing: chat.key) == "title" {
                                    let chatID = Int(snapshot.key)!
                                    let title = String(describing: chat.value)
                                    
                                    availableChats.append([chatID: title])
                                    self.newMessageObserver(chatID: chatID)
                                    
                                    NotificationCenter.default.post(name: .chatsVCTableViewMustBeReload, object: nil, userInfo: nil)
                                }
                            }
                        })
                    }
                    
                    chatID += 1
                }
            }
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
        let messagesDB = self.getMessagesDatabaseReference(chatID: chatID)
        
        let messageDictionary : NSDictionary = ["sender" : sender, "message" : message]
        
        messagesDB.child(String(describing: Int(Date().timeIntervalSinceReferenceDate))).setValue(messageDictionary) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func getMessagesDatabaseReference(chatID: Int) -> DatabaseReference {
        return Database.database().reference().child("chats").child(String(chatID)).child("messages")
    }
    
    func newMessageObserver(chatID: Int) {
        let chatMessagesDB = self.getMessagesDatabaseReference(chatID: chatID)
        
        chatMessagesDB.observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                let message = snapshot.value as! NSDictionary
                if let sender = message["sender"], let message = message["message"] {
                    if chatsData != nil {
                        if var chatMassages = chatsData[chatID] {
                            let massage = Massage(sender: String(describing: sender), message: String(describing: message))
                            chatMassages.append(massage)
                            
                            chatsData[chatID] = chatMassages
                        } else {
                            chatsData[chatID] = [Massage(sender: String(describing: sender), message: String(describing: message))]
                        }
                    } else {
                        chatsData = [chatID: [Massage(sender: String(describing: sender), message: String(describing: message))]]
                    }
                    
                    NotificationCenter.default.post(name: .newMessage, object: nil, userInfo: [chatID: [chatID: snapshot]])
                }
            }
        })
    }
}

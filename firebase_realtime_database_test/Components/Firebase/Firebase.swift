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
                self.addNewUser(userID: email)
                
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
                self.addNewUser(userID: email)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatsNC = storyboard.instantiateViewController(withIdentifier: "chatsNavigationController")
                currentUser = email
                
                self.loginVC.present(chatsNC, animated: true)
            }
        })
    }
    
    func loginAnonymous() {
        Auth.auth().createUser(withEmail: App.testUsername, password: App.testPassword, completion: { (user, error) in
            self.addNewUser(userID: App.testUsername)
            self.emailLogin(email: App.testUsername, password: App.testPassword)
        })
    }
    
    func addNewUser(userID: String) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!)
        
        userDB.child("id").setValue(userID) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func addNewChat(title: String) {
        let chatsDB = Database.database().reference().child("chats")
        
        chatsDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let chatID = snapshot.childrenCount + 1
            
            let chatsDB = Database.database().reference().child("chats").child(String(chatID))
            
            let chatDictionary = ["title" : title, "owner" : currentUser]
            
            chatsDB.setValue(chatDictionary) { (error, ref) in
                if error != nil {
                    print(error!)
                }
            }
        })
    }
    
    func newChatObserver() {
        let chatDB = Database.database().reference().child("chats")
        chatDB.observe(.childAdded, with: { (snapshot) -> Void in
            let userDB = Database.database().reference().child("users").child(currentUser.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!).child("chats").child(snapshot.key)
            userDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                if String(describing: snapshot.value!) == "<null>" {
                    let chatDB = Database.database().reference().child("chats").child(snapshot.key)
                    chatDB.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                        let chat = snapshot.value as! NSDictionary
                        
                        let chatID = snapshot.key
                        let title = String(describing: chat["title"]!)
                        let owner = String(describing: chat["owner"]!)

                        NotificationCenter.default.post(name: .newChatWasCreated, object: nil, userInfo: [chatID: ["chatID": chatID, "title": title, "owner": owner]])
                    })
                }
            })
        })
    }
    
    func addNewChatToUser(userID: String, chatID: Int, status: Bool) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!).child("chats")
        
        userDB.child(String(describing: chatID)).setValue(status) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func newUserChatObserver(userID: String) {
        let userDB = Database.database().reference().child("users").child(userID.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!).child("chats")
        
        userDB.observe(.childAdded, with: { (snapshot) -> Void in
            let chatID = Int(snapshot.key)!
            let status = snapshot.value! as? Bool
            
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
        })
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homepageNC = storyboard.instantiateViewController(withIdentifier: "homepageNavigationController")
            currentUser = String()
            
            self.chatVC.present(homepageNC, animated: true)
        } catch {
            print(error)
        }
    }
    
    func setMessage(sender: String, message: String, chatID: Int) {
        let messagesDB = self.getMessagesDatabaseReference(chatID: chatID)
        
        let messageDictionary = ["sender" : sender, "message" : message]
        
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
                    if String(describing: sender) != currentUser {
                        chatMessagesDB.child(snapshot.key).removeValue()
                    }
                    
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

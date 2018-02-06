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
                let chatVC = storyboard.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
                currentUser = email
                
                self.signInVC.present(chatVC, animated: true)
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
                let chatVC = storyboard.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
                currentUser = email
                
                self.loginVC.present(chatVC, animated: true)
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
            print("logout successful")
        }
        catch {
            print(error)
        }
    }
    
    func setData(sender: String, message: String) {
        let messagesDB = Database.database().reference().child("messages")
        
        let messageDictionary : NSDictionary = ["sender" : sender, "message" : message]
        
        messagesDB.child(String(describing: Int(Date().timeIntervalSinceReferenceDate))).setValue(messageDictionary) {
            (error, ref) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
            }
        }
    }
    
    func getData() {
        let messageDB = Database.database().reference().child("messages")
        
        messageDB.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChildren() {
                let messages = snapshot.value as! NSDictionary
                for message in messages {
                    let messageData = message.value as! NSDictionary
                    if let message = messageData["message"], let sender = messageData["sender"] {
                        self.chatVC.chat.addMessageToScrollView(controller: self.chatVC, sender: sender as! String, message: message as! String)
                    }
                }
            }
        }
    }
}

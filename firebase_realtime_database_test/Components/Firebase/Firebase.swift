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
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
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
            let messages = snapshot.value as! NSDictionary
            var key = CGFloat(0)
            for message in messages {
                let messageData = message.value as! NSDictionary
                if let text = messageData["message"], let sender = messageData["sender"] {
                    let labelHeight = CGFloat(25)
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.chatVC.messagesScrollView.frame.size.width, height: labelHeight))
                    
                    if key > 0 {
                        label.frame.origin.y = labelHeight * key
                    }

                    key += 1
                    label.text = "\(sender): \(text)"
                    self.chatVC.messagesScrollView.addSubview(label)
                    self.chatVC.messagesScrollView.contentSize = CGSize(width: self.chatVC.messagesScrollView.frame.size.width, height: label.frame.origin.y + labelHeight)
                }
            }
        }
    }
}

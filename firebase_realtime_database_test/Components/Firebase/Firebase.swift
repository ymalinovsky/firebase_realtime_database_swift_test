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
        
        messageDB.observeSingleEvent(of: .childAdded) { snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["message"] as! String
            let sender = snapshotValue["sender"] as! String
            
            print(text)
            print(sender)
        }
    }
}

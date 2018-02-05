//
//  LoginViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebase = Firebase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebase.loginVC = self
    }

    @IBAction func LoginButtonAction(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            firebase.emailLogin(email: email, password: password)
        }
    }
    
    @IBAction func anonymousLoginButtonAction(_ sender: UIButton) {
        firebase.loginAnonymous()
    }
    
}

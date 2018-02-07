//
//  SignInViewController.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebase.signInVC = self
    }

    @IBAction func SignInButtonAction(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            firebase.emailRegistration(email: email, password: password)
        }
    }
}


//
//  LoginViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-25.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{
    let email = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    @IBOutlet weak var loginUIView: UIView!
    @IBOutlet weak var usernameTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!

    static var username: String = ""
    static var password: String = ""
    
    @IBAction func tappedLoginButton(_ sender: LoginButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        if (email.Auth(User: username.trim(), Password: password)) {
            LoginViewController.username = username
            LoginViewController.password = password
            routeToListHomeScreen()
        } else {
            presentAlertMessage()
        }
    }
    
    @IBAction func tappedCancelButton(_ sender: CancelButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func presentAlertMessage() {
        let message = "⚠️ Invalid login: Incorrect username or password"
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        alert.view.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        self.present(alert, animated: true, completion: nil)
    }
    
    func routeToListHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationNVC = storyboard.instantiateViewController(withIdentifier: "MainScreen") as! UINavigationController

        self.show(destinationNVC, sender: nil)
    }

}

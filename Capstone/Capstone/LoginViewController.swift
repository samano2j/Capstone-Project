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
    
    @IBAction func tappedLoginButton(_ sender: LoginButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        if (email.Auth(User: username.trim(), Password: password)) {
            // performSegue(withIdentifier: "showListOfMessages", sender: sender)
            routeToListContacts()
        } else {
            //routeToListContacts()
            presentAlertMessage()
        }
//        didLogin(method: "username and password", info: "\nUsername: \(username)\n Password: \(password)")
    }
    
    @IBAction func tappedCancelButton(_ sender: CancelButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            usernameTextField.becomeFirstResponder()
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
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
    
    private func didLogin(method: String, info: String) {
        let message = "Successfully logged in with \(method). " + info
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertMessage() {
        let message = "⚠️ Invalid login: Incorrect username or password"
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        alert.view.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        self.present(alert, animated: true, completion: nil)
    }
    
    func routeToListContacts() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "MainScreen") 
        
//        let contentVC = storyboard.instantiateViewController(withIdentifier: "ContentViewController") as! MailContentTableViewController
//        contentVC.eMail = email
        
        self.show(destinationVC, sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

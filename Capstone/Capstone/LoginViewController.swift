//
//  LoginViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-25.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func tappedLoginButton(_ sender: LoginButton){
        guard let email = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        didLogin(method: "email and password", info: "Email: \(email) \n Password: \(password)")
    }
    
    private func didLogin(method: String, info: String) {
        let message = "Successfully logged in with \(method). " + info
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

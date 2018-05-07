//
//  FirstViewController.swift
//  Musu
//
//  Created by Richard Zarth on 4/19/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

/*
 * TODO LIST
 *
 * Set NSAllowsArbitraryLoads to NO (Info.plist)
 *
 */

import UIKit

// Keychain Configuration
// https://www.raywenderlich.com/179924/secure-ios-user-data-keychain-biometrics-face-id-touch-id
struct KeychainConfiguration {
    static let serviceName = "Musu"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLoginStatus(to: String) {
        loginStatusLabel.text = to
    }
    
    //MARK: Actions

    @IBAction func loginButton(_ sender: UIButton) {
        // Dismiss the keyboard when login button is pressed
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        let jsonPayload = [
            "function": "loginWithUsername",
            "username": username,
            "password": password,
            ] as! Dictionary<String, String>
        
        callAPI(withJSON: jsonPayload) { (jsonResponse) in
            if let success = jsonResponse["success"] as? Int {
                if (success == 1) {
                    
                    print(jsonResponse)
                    print("----------")
                    print(jsonResponse["results"] as? [String: Any] as Any)
                    
                    guard let jsonResults = jsonResponse["results"] as? [String: Any],
                          let token = jsonResults["token"] as? String,
                          let userID = jsonResults["userID"] as? Int
                    else {
                        fatalError("Problem with username and/or token")
                    }
                    
                    do {
                        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                             account: String(userID),
                                                             accessGroup: KeychainConfiguration.accessGroup)

                        try tokenItem.savePassword(token)
                        
                        UserDefaults.standard.set(userID, forKey: "userID")
                        UserDefaults.standard.set(true, forKey: "hasTokenSaved")
                    } catch {
                        fatalError("Error updating Keychain - \(error)")
                    }
                    
                    self.performSegue(withIdentifier: "LoginToStreamSegue", sender: self)
                    DispatchQueue.main.async {
                        self.changeLoginStatus(to: (jsonResponse["message"])! as! String)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.changeLoginStatus(to: (jsonResponse["error"])! as! String)
                    }
                }
            }
        }
    }
}
// https://developer.apple.com/documentation/code_diagnostics/main_thread_checker


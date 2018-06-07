/*
 * TODO LIST
 *
 * Set NSAllowsArbitraryLoads to NO (Info.plist)
 *
 */

import UIKit

// https://www.raywenderlich.com/179924/secure-ios-user-data-keychain-biometrics-face-id-touch-id
struct KeychainConfiguration {
    static let serviceName = "Musu"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.underlined()
        passwordTextField.underlined()
        
        loginButton.layer.cornerRadius = 4
        
        attemptAutoLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func changeLoginStatus(to newStatus: String) {
        loginStatusLabel.text = newStatus
    }
    
    private func attemptAutoLogin() {
        print("attemptAutoLogin(): Attempting silent automatic login...")
        
        // If the hasTokenSaved key is set...
        if let hasTokenSaved = UserDefaults.standard.object(forKey: "hasTokenSaved") as? Bool {
            // And the hasTokenSaved key is set to true...
            if hasTokenSaved {
                print("attemptAutoLogin(): hasTokenSaved UserDefaults key found as true.")
                
                // Build the JSON payload
                let jsonPayload = [
                    "function": "loginWithToken",
                    "userID": getUserID(),
                    "token": getToken(),
                ]
                
                callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
                    if successful {
                        print ("attemptAutoLogin(): Automatic login successful!")
                        self.performSegue(withIdentifier: "LoginToStreamSegue", sender: self)
                    } else {
                        // Silently fail
                        
                        if let error = jsonResponse["error"] as? String {
                            print("attemptAutoLogin(): Automatic login failed: \(error)")
                        } else {
                            print("attemptAutoLogin(): Could not parse jsonRepsonse[\"error\"].")
                        }
                    }
                }
            } else {
                print("attemptAutoLogin(): hasTokenSaved UserDefaults key found as false.")
            }
        } else {
            // Silently fail
            print("attemptAutoLogin(): hasTokenSaved UserDefaults key not found.")
        }
    }
    
    private func updateKeychain(_ token: String, _ userID: Int) {
        do {
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                 account: String(userID),
                                                 accessGroup: KeychainConfiguration.accessGroup)
            
            try tokenItem.savePassword(token)
            
            UserDefaults.standard.set(userID, forKey: "userID")
            UserDefaults.standard.set(true, forKey: "hasTokenSaved")
        } catch let error {
            fatalError("updateKeychain(): \(error)")
        }
    }
    
    private func loginAttempt(Completion block: @escaping (String) -> ()) {
        guard let username = usernameTextField.text else {
            fatalError("loginAttempt(): Could not get username from text field.")
        }
        
        guard let password = passwordTextField.text else {
            fatalError("loginAttempt(): Could not get password from text field.")
        }
        
        let jsonPayload = [
            "function": "loginWithUsername",
            "username": username,
            "password": password,
        ]
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
                guard let results = jsonResponse["results"] as? [String: Any],
                      let token = results["token"] as? String,
                      let userID = results["userID"] as? Int else {
                    fatalError("loginAttempt(): Could not parse token and userID for updateKeychain().")
                }
                
                self.updateKeychain(token, userID)
                
                self.performSegue(withIdentifier: "LoginToStreamSegue", sender: self)
                
                block("...")
            } else {
                if let message = jsonResponse["error"] as? String {
                    block(message)
                } else {
                    block("Could not parse error message.")
                }
            }
        }
    }
    
    private func dismissAllKeyboards() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    // MARK: Actions

    // https://stackoverflow.com/a/32798799
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        // TODO: Should this be empty?
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        dismissAllKeyboards()
        
        loginAttempt() { status in
            DispatchQueue.main.async {
                self.changeLoginStatus(to: status)
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
}


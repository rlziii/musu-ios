import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var newFirstNameTextField: UITextField!
    @IBOutlet weak var newLastNameTextField: UITextField!
    @IBOutlet weak var newUsernameTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordVerifyTextField: UITextField!
    @IBOutlet weak var newEmailAddressTextField: UITextField!
    
    @IBOutlet weak var updateUserStatusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func changeUpdateUserStatus(to newStatus: String) {
        updateUserStatusLabel.text = newStatus
    }
    
    private func clearKeychain() {
        // TODO: Potentially update this to call the API logout endpoint
        
        do {
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                 account: getUserID(),
                                                 accessGroup: KeychainConfiguration.accessGroup)
            
            try tokenItem.deleteItem()
            print("Token deleted from Keychain.")
        } catch {
            print("Token could not be deleted from Keychain")
        }
        
        UserDefaults.standard.set(0, forKey: "userID")
        print("userID set to '0' in UserDefaults")
        
        UserDefaults.standard.set(false, forKey: "hasTokenSaved")
        print("hasTokenSaved set to 'false' in UserDefaults")
    }
    
    private func dismissAllKeybaords() {
        self.newFirstNameTextField.resignFirstResponder()
        self.newLastNameTextField.resignFirstResponder()
        self.newUsernameTextField.resignFirstResponder()
        self.newPasswordTextField.resignFirstResponder()
        self.newPasswordVerifyTextField.resignFirstResponder()
        self.newEmailAddressTextField.resignFirstResponder()
    }
    
    private func updateUser(Completion block: @escaping (String) -> ()) {
        guard let firstName = newFirstNameTextField.text,
              let lastName = newLastNameTextField.text,
              let username = newUsernameTextField.text,
              let password = newPasswordTextField.text,
              let passwordVerify = newPasswordVerifyTextField.text,
              let emailAddress = newEmailAddressTextField.text else {
            fatalError("updateUser(): Not all text fields could be converted to strings.")
        }
        
        if (password != "") && (password != passwordVerify) {
            return block("Passwords do not match.")
        }
        
        if firstName == "" && lastName == "" && username == "" && password == "" && emailAddress == "" {
            return block("At least one field must be filled out.")
        }
        
        let jsonPayload = [
            "function": "updateUser",
            "userID": getUserID(),
            "token": getToken(),
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "password": password,
            "emailAddress": emailAddress,
        ]
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
                if let message = jsonResponse["message"] as? String {
                    block(message)
                } else {
                    block("Could not parse success message.")
                }
            } else {
                if let message = jsonResponse["error"] as? String {
                    block(message)
                } else {
                    block("Could not parse error message.")
                }
            }
        }
    }
    
    //MARK: Actions

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        clearKeychain()
        
        self.performSegue(withIdentifier: "LogoutSegue", sender: self)
    }
    
    @IBAction func updateUserButtonTapped(_ sender: UIButton) {
        updateUser() { status in
            DispatchQueue.main.async {
                self.changeUpdateUserStatus(to: status)
            }
        }
    }
    
}

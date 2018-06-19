import UIKit

class CreateUserViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerifyTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var createUserStatusLabel: UILabel!
    @IBOutlet weak var createUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.underlined()
        lastNameTextField.underlined()
        usernameTextField.underlined()
        passwordTextField.underlined()
        passwordVerifyTextField.underlined()
        emailAddressTextField.underlined()
        
        createUserButton.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func changeCreateUserStatus(to newStatus: String) {
        createUserStatusLabel.text = newStatus
    }

    private func dismissAllKeyboards() {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordVerifyTextField.resignFirstResponder()
        self.emailAddressTextField.resignFirstResponder()
    }
    
    private func createUser(Completion block: @escaping (String) -> ()) {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let username = usernameTextField.text,
              let password = passwordTextField.text,
              let passwordVerify = passwordVerifyTextField.text,
              let emailAddress = emailAddressTextField.text else {
            fatalError("createUser(): Not all text fields could be converted to strings.")
        }
        
        if password != passwordVerify {
            return block("Passwords do not match.")
        }
        
        if firstName == "" || lastName == "" || username == "" || password == "" || emailAddress == "" {
            return block("Not all fields are filled out.")
        }
        
        let jsonPayload = [
            "function": "createUser",
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
    
    // MARK: Actions

    @IBAction func createUserButtonTapped(_ sender: UIButton) {
        dismissAllKeyboards()
        
        createUser() { status in
            DispatchQueue.main.async {
                self.changeCreateUserStatus(to: status)
            }
        }
    }
    
}

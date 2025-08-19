import UIKit
import SwiftKeychainWrapper

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        password.delegate = self
        
        userName.returnKeyType = .next
        password.returnKeyType = .go
        password.isSecureTextEntry = true

        // Eye button for password
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        password.rightView = eyeButton
        password.rightViewMode = .always
    }

    // Toggle password visibility
    @objc private func togglePasswordVisibility() {
        password.isSecureTextEntry.toggle()
        let existingText = password.text
        password.text = ""
        password.text = existingText
        if let button = password.rightView as? UIButton {
            let imageName = password.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    // Handle keyboard return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userName {
            password.becomeFirstResponder()
        } else if textField == password {
            textField.resignFirstResponder()
            loginButton.sendActions(for: .touchUpInside)
        }
        return true
    }

    // MARK: - Login
    @IBAction func PressedLogin(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let phone = userName.text, !phone.isEmpty,
              let pass = password.text, !pass.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter phone and password")
            return
        }

       
        NetworkManager.shared.login(username: phone, password: pass) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(" Token saved: \(response.token)")
                    
                    // Navigate to Home
                    if let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") {
                        homeVC.modalPresentationStyle = .fullScreen
                        self.present(homeVC, animated: true, completion: nil)
                    }

                case .failure(let error):
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helper Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
